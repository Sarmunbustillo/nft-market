# NFT market place app

Buy, sell and transfer Nfts

## Tech

React, Nextjs, Typescript, Tailwind, Ganache, Truffle, Pinata nft cloud

## Development

You need to install Ganache and Truffle for blockchain enviroment (and have Ganache open) (default account is always the first one accounts[0])

you can import a Ganache account **private key** into your metaMask for testing

Run `sudo truffle migrate --reset` to upload contracts to Ganache

Run `sudo truffle console` to enter the truffle console to run commands

Run `sudo truffle test` for testing

Run `pnpm run genContractType` to generate contract types

## Deploying to Ropsten network

Create a new project in https://infura.io/

You can add Eth to your Robsten enviroment here https://faucet.egorfine.com/ pasting your wallet address

Run `sudo truffle migrate --network ropsten` to migrate contracts to ropsten network

## Deploying to Vercel

add your enviromental variables to deploy
