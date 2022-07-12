import { Web3Dependencies } from '@_types/hooks';
import { hookFactory as createAccountHook, UseAccountHook } from './useAccount';
import { hookFactory as createNetworkHook, UseNetworkHook } from './useNetwork';
import {
    hookFactory as createListedNftsHook,
    UseListedNftsHook,
} from './useListedNfts';

export type Web3Hooks = {
    useAccount: UseAccountHook;
    useNetwork: UseNetworkHook;
    useListedNfts: UseListedNftsHook;
};

export type SetupHooks = {
    (d: Web3Dependencies): Web3Hooks;
};

export const SetupHooks: SetupHooks = (dependencies) => {
    return {
        useAccount: createAccountHook(dependencies),
        useNetwork: createNetworkHook(dependencies),
        useListedNfts: createListedNftsHook(dependencies),
    };
};
