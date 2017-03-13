var accounts = [];
var accountNames = {};

addAccount(eth.accounts[0], "Account #0 - Miner");
addAccount(eth.accounts[1], "Account #1 - Owner");
addAccount(eth.accounts[2], "Account #2 - Preallocation Participant #1");
addAccount(eth.accounts[3], "Account #3 - Preallocation Participant #2");
addAccount(eth.accounts[4], "Account #4 - Presale Participant #1");

var ownerAccount = eth.accounts[1];
var preallocationParticipant1Account = eth.accounts[2];
var preallocationParticipant2Account = eth.accounts[3];
var presaleParticipant1Account = eth.accounts[4];

function unlockAccounts(password) {
  for (var i = 0; i < 5; i++) {
    personal.unlockAccount(eth.accounts[i], password, 100000);
  }
}

function addAccount(account, accountName) {
  accounts.push(account);
  accountNames[account] = accountName;
}

function printBalances() {
  var i = 0;
  console.log("RESULT: # Account                                                   EtherBalance Name");
  accounts.forEach(function(e) {
    i++;
    var etherBalance = web3.fromWei(eth.getBalance(e), "ether");
    console.log("RESULT: " + i + " " + e  + " " + pad(etherBalance) + " " + accountNames[e]);
  });
}

function pad(s) {
  var o = s.toFixed(18);
  while (o.length < 27) {
    o = " " + o;
  }
  return o;
}

function printTxData(name, txId) {
  var tx = eth.getTransaction(txId);
  var txReceipt = eth.getTransactionReceipt(txId);
  console.log("RESULT: " + name + " gas=" + tx.gas + " gasUsed=" + txReceipt.gasUsed + " cost=" + tx.gasPrice.mul(txReceipt.gasUsed).div(1e18) +
    " block=" + txReceipt.blockNumber + " txId=" + txId);
}

function assertEtherBalance(account, expectedBalance) {
  var etherBalance = web3.fromWei(eth.getBalance(account), "ether");
  if (etherBalance == expectedBalance) {
    console.log("RESULT: OK " + account + " has expected balance " + expectedBalance);
  } else {
    console.log("RESULT: FAILURE " + account + " has balance " + etherBalance + " <> expected " + expectedBalance);
  }
}

