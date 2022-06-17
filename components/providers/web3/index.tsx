import { createContext, useContext, useEffect, useState } from 'react';
import { createDefaultState, loadContract, Web3State } from '@providers/utils';
import { ethers } from 'ethers';

interface Props {
    children: React.ReactNode;
}

const Web3Context = createContext<Web3State>(createDefaultState());

const Web3Provider: React.FC<Props> = ({ children }) => {
    const [web3Api, setWeb3Api] = useState<Web3State>(createDefaultState());

    useEffect(() => {
        async function iniWeb3() {
            const provider = new ethers.providers.Web3Provider(
                window.ethereum as any
            );
            const contract = await loadContract('NftMarket', provider);
            setWeb3Api({
                ethereum: window.ethereum,
                provider,
                contract,
                isLoading: false,
            });
        }

        iniWeb3();
        return () => {};
    }, []);

    return (
        <Web3Context.Provider value={web3Api}>{children}</Web3Context.Provider>
    );
};

export function useWeb3() {
    return useContext(Web3Context);
}
export default Web3Provider;
