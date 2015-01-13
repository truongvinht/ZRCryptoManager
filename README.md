ZRCryptoManager
----------------------------------

**description**

Collection of classes to access crypto coins information quickly and easily

**features:**

- read different types of wallet addresses
- read ticker information (TODO)

#Example

Read wallet address:

```Objective-C

    [[ZRRequestConnector sharedInstance] setDelegate:self];
		[[ZRRequestConnector sharedInstance] requestWalletValue:@"BTC" forAddress:@"ANY_VALID_ADDRESS"];
```

Implement following method to get the response:
```Objective-C
	- (void)didReceiveWalletData:(NSDictionary *)walletData
```
#License
MIT License (MIT)

