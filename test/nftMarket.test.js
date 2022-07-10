const NftMarket = artifacts.require('NftMarket');
const { ethers } = require('ethers');

contract('NftMarket', (accounts) => {
    let _contract = null;
    let _listingPrice = ethers.utils.parseEther('0.025').toString();
    let _nftPrice = ethers.utils.parseEther('0.3').toString();

    before(async () => {
        _contract = await NftMarket.deployed();
    });

    describe('Mint token', () => {
        const tokenURI = 'https://test.com';
        before(async () => {
            await _contract.mintToken(tokenURI, _nftPrice, {
                from: accounts[0],
                value: _listingPrice,
            });
        });

        it('owner of the first token should be address[0]', async () => {
            const owner = await _contract.ownerOf(1);
            assert.equal(
                owner,
                accounts[0],
                'Owner of token does not match address[0]'
            );
        });
        it('first token should point to the correct tokenURI', async () => {
            const actualtokenURI = await _contract.tokenURI(1);
            assert.equal(
                actualtokenURI,
                tokenURI,
                'tokenURI is not correctly set'
            );
        });
        it('should not be possible to create a NFT with used tokenURI', async () => {
            try {
                await _contract.mintToken(tokenURI, _nftPrice, {
                    from: accounts[0],
                });
            } catch (error) {
                assert(error, 'NFT was minted with previously used tokenURI');
            }
        });

        it('should have one listed item', async () => {
            const listedItemCount = await _contract.listedItemsCount();
            assert.equal(
                listedItemCount.toNumber(),
                1,
                'listed item count is not 1'
            );
        });
        it('should create NFT item', async () => {
            const nftItem = await _contract.getNftItem(1);
            console.log(nftItem);
            assert.equal(nftItem.tokenId, 1, 'token id is not 1');
            assert.equal(nftItem.price, _nftPrice, 'Nft price is not correct ');
            assert.equal(
                nftItem.creator,
                accounts[0],
                'account is not account[0]'
            );
            assert.equal(nftItem.isListed, true, 'token is not listed');
        });
    });

    describe('Buy NFT', () => {
        before(async () => {
            await _contract.buyNft(1, {
                from: accounts[1],
                value: _nftPrice,
            });
        });

        it('should unlist the item', async () => {
            const listedItem = await _contract.getNftItem(1);
            assert.equal(listedItem.isListed, false, 'Item is still listed');
        });
        it('should decrease the item listed count', async () => {
            const listedItemsCount = await _contract.listedItemsCount();
            assert.equal(
                listedItemsCount.toNumber(),
                0,
                'Count has not been decremented'
            );
        });
        it('should change the owner', async () => {
            const currentOwner = await _contract.ownerOf(1);
            assert.equal(
                currentOwner,
                accounts[1],
                'owner and buyer are the same account'
            );
        });
    });
});
