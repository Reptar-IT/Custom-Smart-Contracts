About Project
-------------
This project was designed to assist the evaluation of a business/organization thus clarifying it's stock/share price "true worth". This model allows a public and accurate calculation of income. Even dividends can easily be tracked and traced. Shares can transfered freely. Shares can also be lent out to individuals, other businesess or organizations for a period of time to allow them to benefit from gained dividends before being reposessed.

Scenario #1. If 1000 DaleyReco tokens exist and Bob owns 60% of the DaleyReco organization Bob must own 60% of existing DaleyReco tokens. If on a specific day The DaleyReco organiazation earned 100 ETH then Bob has claim to withdraw 60 ETH.

Scenario #2. If Bob lent mary 100 DaleyReco Tokens for 1 day Mary now has 10% of DaleyReco tokens. Bob will not be able to reposess the 100 DaleyReco token until 24hrs has passed. If on the specific day The DaleyReco organiazation earned 100 ETH then Mary has claim to withdraw 10 ETH. Mary will continue to be able to withdraw ETH dividends even after the 1 day has passed until Bob decide to reposess the DaleyReco Tokens from Mary.


DaleyReco.sol
-------------

A transfereable token used as a share/stock in an organization or ecosystem.

Token has address function and can recieve payments

Token holders are shareholders. Shareholders can withdraw respective dividends immediately after a payment was recieved.

Token can be set as beneficiary in escrow contracts.


functionality test checklist
----------------------------
cant send whats owed: check
cant retract before bond expires: check
total bond value of borrower: check
loan value between to and from accounts: check
loan expirey between to and from accounts: check
retraction:  succes
cannot retract more that what was owed: check
cannot approve allowance to owed funds: check
cannot retract what you did not lend: check

Token Specification
-------------------
Token Address: 0xD58BaD4146A649a15d0620de3b5eE6A948A59336
Etherscan link: https://etherscan.io/address/0xd58bad4146a649a15d0620de3b5ee6a948a59336
Creator: 0x1eCD8a6Bf1fdB629b3e47957178760962C91b7ca
Name: Daley
Symbol: RECO
Decimal places: 0
Total Supply: 200000000


Functionalities
----------------
- Time locked Lending
- Realtime profit dividend distribution mechanism
- Transferable token currency
- Proof of ownership of Shares
- The actual security asset / share


EscrowForDaleyReco.sol
----------------------

Escrow contracts can be used "as is" or modified to function as payment processor to recieve payments from sales, fees or dividends from other contracts.
