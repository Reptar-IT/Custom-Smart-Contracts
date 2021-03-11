DailyRICO.sol
----------------

A transfereable token used as a share/stock in an organization or ecosystem.

Token has address function and can recieve payments

Token holders are shareholders. Shareholders can withdraw respective dividends immediately after a payment was recieved.

Token can be set as beneficiary in escrow contracts.


cant send whats owed: check
cant retract before bond expires: check
total bond value of borrower: check
loan value between to and from accounts: check
loan expirey between to and from accounts: check
retraction:  succes
cannot retract more that what was owed: check
cannot approve allowance to owed funds: check
cannot retract what you did not lend: check

Token Address: 0xD58BaD4146A649a15d0620de3b5eE6A948A59336
Etherscan link: https://etherscan.io/address/0xd58bad4146a649a15d0620de3b5ee6a948a59336
Creator: 0x1eCD8a6Bf1fdB629b3e47957178760962C91b7ca
Name: Daley
Symbol: RECO
Decimal places: 0
Total Supply: 200000000

Functionalities:

- Time locked Lending
- Realtime profit dividend distribution mechanism
- Transferable token currency
- Proof of ownership of Shares
- The actual security asset / share


EscrowForDailyReco.sol
------------------------

Escrow contracts can be used "as is" or modified to function as payment processor to recieve payments from sales, fees or dividends from other contracts.
