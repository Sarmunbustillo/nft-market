import { createContext, useContext, useEffect, useState } from 'react';
import {
    createDefaultState,
    createweb3State,
    loadContract,
    Web3State,
} from '@providers/web3/utils';
import { ethers } from 'ethers';
import { MetaMaskInpageProvider } from '@metamask/providers';
import { NftMarketContract } from '@_types/nftMarketContract';

interface Props {
    children: React.ReactNode;
}

const pageReload = () => window.location.reload();
const handleAccount = (ethereum: MetaMaskInpageProvider) => async () => {
    // isUnlocked returns true if the user is logged out, so we convert that true to a false
    const isLocked = !(await ethereum._metamask.isUnlocked());

    if (isLocked) {
        pageReload();
    }
};

const setGlobalListeners = (ethereum: MetaMaskInpageProvider) => {
    ethereum.on('chainChanged', pageReload);
    ethereum.on('accountsChanged', handleAccount(ethereum));
};
const removeGlobalListeners = (ethereum: MetaMaskInpageProvider) => {
    ethereum?.removeListener('chainChanged', pageReload);
    ethereum?.removeListener('accountsChanged', handleAccount);
};

const Web3Context = createContext<Web3State>(createDefaultState());

const Web3Provider: React.FC<Props> = ({ children }) => {
    const [web3Api, setWeb3Api] = useState<Web3State>(createDefaultState());

    useEffect(() => {
        async function iniWeb3() {
            try {
                const provider = new ethers.providers.Web3Provider(
                    window.ethereum as any
                );
                const contract = await loadContract('NftMarket', provider);

                //sign contract
                const signer = provider.getSigner();
                const signedContract = contract.connect(signer);

                setTimeout(() => {
                    setGlobalListeners(window.ethereum);
                }, 100);

                setWeb3Api(
                    createweb3State({
                        ethereum: window.ethereum,
                        provider,
                        contract:
                            signedContract as unknown as NftMarketContract,
                        isLoading: false,
                    })
                );
            } catch (error: any) {
                console.error('Please Install web3 wallet');
                setWeb3Api((api) =>
                    createweb3State({
                        ...(api as any),
                        isLoading: false,
                    })
                );
            }
        }

        iniWeb3();
        return () => removeGlobalListeners(window.ethereum);
    }, []);

    return (
        <Web3Context.Provider value={web3Api}>{children}</Web3Context.Provider>
    );
};

export function useWeb3() {
    return useContext(Web3Context);
}

export function useHooks() {
    const { hooks } = useWeb3();
    return hooks;
}

export default Web3Provider;
