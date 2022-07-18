import { useListedNfts } from '@hooks/web3';
import { FunctionComponent } from 'react';
import NftItem from '../item';
import { v4 as uuidv4 } from 'uuid';

const NftList: FunctionComponent = () => {
    const { nfts } = useListedNfts();
    return (
        <div className="mt-12 max-w-lg mx-auto grid gap-5 lg:grid-cols-3 lg:max-w-none ">
            {nfts.data?.map((nft) => (
                <div
                    key={nft.meta.image + uuidv4()}
                    className="flex flex-col  group  rounded-lg  shadow-lg "
                >
                    <NftItem item={nft} buyNft={nfts.buyNft} />
                </div>
            ))}
        </div>
    );
};

export default NftList;
