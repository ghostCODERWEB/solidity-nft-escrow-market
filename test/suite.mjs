export async function suite(h) {
  const token = await h.token();
  const nft = await h.nft();
  const c = await h.deploy("NFTMarket", [
    token.target,
    250,
    h.addresses[3],
    h.addresses[0],
  ]);
  await h.tx(nft.approve(c.target, 1));
  await h.tx(c.list(nft.target, 1, 1000, h.addresses[2], 500));
  await h.tx(token.mint(h.addresses[1], 1000));
  await h.tx(token.connect(h.signers[1]).approve(c.target, 1000));
  await h.test("NFT is escrowed", async () =>
    h.eq(await nft.ownerOf(1), c.target),
  );
  await h.test("unauthorized cancellation rejected", () =>
    h.revert(() => c.connect(h.signers[1]).cancel(1)),
  );
  await h.test("price ceiling enforced", () =>
    h.revert(() => c.connect(h.signers[1]).buy(1, 999)),
  );
  await h.test("sale transfers NFT and allocates fees", async () => {
    await h.tx(c.connect(h.signers[1]).buy(1, 1000));
    h.eq(await nft.ownerOf(1), h.addresses[1]);
    h.eq(await c.credits(h.addresses[0]), 925n);
    h.eq(await c.credits(h.addresses[2]), 50n);
    h.eq(await c.credits(h.addresses[3]), 25n);
  });
  await h.test("listing cannot sell twice", () =>
    h.revert(() => c.connect(h.signers[1]).buy(1, 1000)),
  );
  await h.test("seller pulls proceeds", async () => {
    await h.tx(c.withdraw());
    h.eq(await c.liability(), 75n);
  });
}
