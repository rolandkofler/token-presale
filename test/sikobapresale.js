var SikobaPresale = artifacts.require("./SikobaPresale.sol");

contract('SikobaPresale', function(accounts) {
  it("should put 10000 SikobaPresale in the first account", function() {
    return SikobaPresale.deployed().then(function(instance) {
      return instance.getBalance.call(accounts[0]);
    }).then(function(balance) {
      assert.equal(balance.valueOf(), 10000, "10000 wasn't in the first account");
    });
  });
  it("should call a function that depends on a linked library", function() {
    var presale;
    var SikobaPresaleBalance;
    var SikobaPresaleEthBalance;

    return SikobaPresale.deployed().then(function(instance) {
      presale = instance;
      return presale.getBalance.call(accounts[0]);
    }).then(function(outCoinBalance) {
      SikobaPresaleBalance = outCoinBalance.toNumber();
      return presale.getBalanceInEth.call(accounts[0]);
    }).then(function(outCoinBalanceEth) {
      SikobaPresaleEthBalance = outCoinBalanceEth.toNumber();
    }).then(function() {
      assert.equal(SikobaPresaleEthBalance, 2 * SikobaPresaleBalance, "Library function returned unexpected function, linkage may be broken");
    });
  });
  it("should send coin correctly", function() {
    var presale;

    // Get initial balances of first and second account.
    var account_one = accounts[0];
    var account_two = accounts[1];

    var account_one_starting_balance;
    var account_two_starting_balance;
    var account_one_ending_balance;
    var account_two_ending_balance;

    var amount = 10;

    return SikobaPresale.deployed().then(function(instance) {
      presale = instance;
      return presale.getBalance.call(account_one);
    }).then(function(balance) {
      account_one_starting_balance = balance.toNumber();
      return presale.getBalance.call(account_two);
    }).then(function(balance) {
      account_two_starting_balance = balance.toNumber();
      return presale.sendCoin(account_two, amount, {from: account_one});
    }).then(function() {
      return presale.getBalance.call(account_one);
    }).then(function(balance) {
      account_one_ending_balance = balance.toNumber();
      return presale.getBalance.call(account_two);
    }).then(function(balance) {
      account_two_ending_balance = balance.toNumber();

      assert.equal(account_one_ending_balance, account_one_starting_balance - amount, "Amount wasn't correctly taken from the sender");
      assert.equal(account_two_ending_balance, account_two_starting_balance + amount, "Amount wasn't correctly sent to the receiver");
    });
  });
});
