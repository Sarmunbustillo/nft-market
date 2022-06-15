import { createContext, useContext, useState } from 'react';
import { createDefaultState, Web3State } from '@providers/utils';

interface Props {
    children: React.ReactNode;
}

const Web3Context = createContext<Web3State>(createDefaultState());

const Web3Provider: React.FC<Props> = ({ children }) => {
    const [web3Api, setWeb3Api] = useState<Web3State>(createDefaultState());
    return (
        <Web3Context.Provider value={web3Api}>{children}</Web3Context.Provider>
    );
};

export function useWeb3() {
    return useContext(Web3Context);
}
export default Web3Provider;