import { CryptoHookFactory } from '@_types/hooks';
import { useEffect } from 'react';
import useSWR from 'swr';

type UseAccountResponse = {
    connect: () => void;
    isLoading: boolean;
    isInstalled: boolean;
};

type AccountHookFactory = CryptoHookFactory<string, UseAccountResponse>;

export type UseAccountHook = ReturnType<AccountHookFactory>;

// deps -> providr, ethereum, contract ()
export const hookFactory: AccountHookFactory =
    ({ provider, ethereum, isLoading }) =>
    () => {
        const { data, mutate, isValidating, ...swr } = useSWR(
            provider ? 'web/useAccount' : null,
            async () => {
                const accounts = await provider!.listAccounts();
                const account = accounts[0];
                if (!account) {
                    throw 'Cannot connect to account! Please connect to Web3 wallet';
                }
                return account;
            },
            { revalidateOnFocus: false, shouldRetryOnError: false }
        );

        useEffect((): any => {
            ethereum?.on('accountsChanged', handleAccountsChanged);

            return () =>
                ethereum?.removeListener(
                    'accountsChanged',
                    handleAccountsChanged
                );
        });

        const handleAccountsChanged = (...args: unknown[]) => {
            const accounts = args[0] as string[];
            if (accounts.length === 0) {
                console.error('Please connect to web3 wallet');
            } else if (accounts[0] !== data) {
                mutate(accounts[0]);
            }
        };

        const connect = async () => {
            try {
                ethereum?.request({ method: 'eth_requestAccounts' });
            } catch (error) {
                console.error(error);
            }
        };
        return {
            ...swr,
            data,
            isValidating,
            isLoading: isLoading as boolean,
            isInstalled: ethereum?.isMetaMask || false,
            mutate,
            connect,
        };
    };

// export const useAccount = hookFactory({
//     ethereum: undefined,
//     provider: undefined,
//     contract: undefined,
// });
