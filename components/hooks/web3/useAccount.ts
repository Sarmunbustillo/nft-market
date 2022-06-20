import { CryptoHookFactory } from '@_types/hooks';
import useSWR from 'swr';

type AccountHookFactory = CryptoHookFactory<string, string>;

export type UseAccountHook = ReturnType<AccountHookFactory>;

// deps -> providr, ethereum, contract ()
export const hookFactory: AccountHookFactory = (deps) => (params) => {
    const swrRes = useSWR('web/useAccount', () => {
        console.log(deps);
        console.log(params);
        //making request to get data
        return 'test user';
    });

    return swrRes;
};

// export const useAccount = hookFactory({
//     ethereum: undefined,
//     provider: undefined,
//     contract: undefined,
// });
