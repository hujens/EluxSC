App = {
    //Initialize variables (TODO: needed?)
    web3Provider: null,
    contracts: {},
    emptyAddress: "0x0000000000000000000000000000000000000000",
    sku: 0,
    upc: 0,
    metamaskAccountID: "0x0000000000000000000000000000000000000000",
    ownerID: "0x0000000000000000000000000000000000000000",
    supplierID: "0x0000000000000000000000000000000000000000",
    supplierName: null,
    supplierInformation: null,
    productNotes: null,
    productPrice: 0,
    contractorName: null,
    contractorInformation: null,
    installationPrice: 0,
    customerID: "0x0000000000000000000000000000000000000000",
    customerName: null,
    amountPay: 0,
    amountBuy: 0,
    check: true,
    address: "0x0000000000000000000000000000000000000000",

    // 
    init: async function () {
        App.readForm();
        /// Setup access to blockchain
        return await App.initWeb3();
    },

    // fetches field entries
    readForm: function () {
        App.sku = $("#sku").val();
        App.upc = $("#upc").val();
        App.upc1 = $("#upc1").val();
        App.upc2 = $("#upc2").val();
        App.upc3 = $("#upc3").val();
        App.upc4 = $("#upc4").val();
        App.upc5 = $("#upc5").val();
        App.upc6 = $("#upc6").val();
        App.upc7 = $("#upc7").val();
        App.upc8 = $("#upc8").val();
        App.upc9 = $("#upc9").val();
        App.ownerID = $("#ownerID").val();
        App.supplierName = $("#supplierName").val();
        App.supplierInformation = $("#supplierInformation").val();
        App.productNotes = $("#productNotes").val();
        App.productPrice = $("#productPrice").val() * 1000000000000000000; //conversion to Wei
        App.contractorName = $("#contractorName").val();
        App.contractorInformation = $("#contractorInformation").val();
        App.installationPrice = $("#installationPrice").val() * 1000000000000000000; //conversion to Wei
        App.customerID = $("#customerID").val();
        App.customerName = $("#customerName").val();
        App.amountPay = $("#amountPay").val();
        App.amountBuy = $("#amountBuy").val();
        App.check = JSON.parse($("#check").val()); //convert to boolean
        App.address = $("#address").val();

        /*
        console.log(
            "sku:", App.sku,
            "/ upc:", App.upc,
            "/ ownerID:", App.ownerID,
            "/ supplierName:", App.supplierName,
            "/ supplierInformation:", App.supplierInformation,
            "/ productNotes:", App.productNotes,
            "/ productPrice:", App.productPrice,
            "/ contractorName:", App.contractorName,
            "/ contractorInformation:", App.contractorInformation,
            "/ installationPrice:", App.installationPrice,
            "/ customerID:", App.customerID,
            "/ customerName:", App.customerName,
            "/ amountPay:", App.amountPay,
            "/ amountBuy:", App.amountBuy,
            "/ check:", App.check
        );*/
    },

    initWeb3: async function () {
        /// Find or Inject Web3 Provider
        /// Modern dapp browsers...
        if (window.ethereum) {
            App.web3Provider = window.ethereum;
            try {
                // Request account access
                await window.ethereum.enable();
            } catch (error) {
                // User denied account access...
                console.error("User denied account access")
            }
        }
        // Legacy dapp browsers...
        else if (window.web3) {
            App.web3Provider = window.web3.currentProvider;
        }
        // If no injected web3 instance is detected, fall back to Ganache (ganache-cli: 7545, UI: 8545)
        else {
            App.web3Provider = new Web3.providers.HttpProvider('http://localhost:7545');
        }

        App.getMetaskAccountID();
    
        return App.initSupplyChain();
    },

    getMetaskAccountID: function () {
        web3 = new Web3(App.web3Provider);

        // Retrieving accounts
        web3.eth.getAccounts(function(err, res) {
            if (err) {
                console.log('Error:',err);
                return;
            }
            console.log('getMetaskID:',res);
            App.metamaskAccountID = res[0];

        })
    },


    initSupplyChain: function () {
        /// Source the truffle compiled smart contracts
        var jsonSupplyChain='../../build/contracts/SupplyChain.json';
        
        /// JSONfy the smart contracts
        $.getJSON(jsonSupplyChain, function(data) {
            console.log('data',data);
            var SupplyChainArtifact = data;
            App.contracts.SupplyChain = TruffleContract(SupplyChainArtifact);
            App.contracts.SupplyChain.setProvider(App.web3Provider);
            
            /*
            App.fetchItemBufferOne();
            App.fetchItemBufferTwo();
            App.fetchItemBufferThree();*/

            //TODO: what does this do?
            App.fetchEvents();
        });

        // listens to "button-clicks"
        return App.bindEvents();
    },

    bindEvents: function() {
        $(document).on('click', App.handleButtonClick);
    },

    handleButtonClick: async function(event) {
        event.preventDefault();

        App.getMetaskAccountID();
        //Update values with field-entries before calling functions
        App.readForm();

        var processId = parseInt($(event.target).data('id'));
        console.log('processId',processId);

        switch(processId) {
            case 1:
                return await App.produceItem(event);
                break;
            case 2:
                return await App.sellItem(event);
                break;
            case 3:
                return await App.buyItem(event);
                break;
            case 4:
                return await App.shipItem(event);
                break;
            case 5:
                return await App.receiveItem(event);
                break;
            case 6:
                return await App.installItem(event);
                break;
            case 7:
                return await App.checkItem(event);
                break;
            case 8:
                return await App.payItem(event);
                break;
            case 9:
                return await App.handOverItem(event);
                break;
            case 10:
                return await App.fetchItem(event);
                break;
            case 11:
                return await App.addSupplier(event);
                break;  
            case 12:
                return await App.addContractor(event);
                break;
            case 13:
                return await App.addCustomer(event);
                break;
            }
    },

    produceItem: function(event) {
        event.preventDefault();
        //var processId = parseInt($(event.target).data('id'));
        console.log(
            "upc:", App.upc1,
            "/ supplierName:", App.supplierName,
            "/ supplierInformation:", App.supplierInformation,
            "/ productNotes:", App.productNotes,
            "/ caller:", App.metamaskAccountID
        );

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.produceItem(
                App.upc1,
                App.supplierName, 
                App.supplierInformation,
                App.productNotes,
                {from: App.metamaskAccountID}
            );
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('produceItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    sellItem: function (event) {
        event.preventDefault();
        //var processId = parseInt($(event.target).data('id'));
        console.log(
            "upc:", App.upc2,
            "/ productPrice:", App.productPrice,
            "/ caller:", App.metamaskAccountID
        );

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.sellItem(
                App.upc2,
                App.productPrice,
                {from: App.metamaskAccountID}
            );
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('sellItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    buyItem: function (event) {
        event.preventDefault();
        //var processId = parseInt($(event.target).data('id'));
        console.log(
            "upc:", App.upc3,
            "/ contractorName:", App.contractorName,
            "/ contractorInformation:", App.contractorInformation,
            "/ customerID:", App.customerID,
            "/ customerName:", App.customerName,
            "/ caller:", App.metamaskAccountID
        );

        App.contracts.SupplyChain.deployed().then(function(instance) {
            const walletValue = web3.toWei(App.amountBuy, "ether");
            return instance.buyItem(
                App.upc3,
                App.contractorName,
                App.contractorInformation,
                App.customerID,
                App.customerName,
                {from: App.metamaskAccountID, value: walletValue}
            );
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('buyItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    shipItem: function (event) {
        event.preventDefault();
        //var processId = parseInt($(event.target).data('id'));
        console.log(
            "upc:", App.upc4,
            "/ caller:", App.metamaskAccountID
        );

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.shipItem(
                App.upc4,
                {from: App.metamaskAccountID}
            );
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('shipItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    receiveItem: function (event) {
        event.preventDefault();
        //var processId = parseInt($(event.target).data('id'));
        console.log(
            "upc:", App.upc5,
            "/ caller:", App.metamaskAccountID
        );

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.receiveItem(
                App.upc5,
                {from: App.metamaskAccountID}
            );
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('receiveItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    installItem: function (event) {
        event.preventDefault();
        //var processId = parseInt($(event.target).data('id'));
        console.log(
            "upc:", App.upc6,
            "/ installationPrice:", App.installationPrice,
            "/ caller:", App.metamaskAccountID
        );

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.installItem(
                App.upc6,
                App.installationPrice,
                {from: App.metamaskAccountID}
            );
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('installItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    checkItem: function (event) {
        event.preventDefault();
        //var processId = parseInt($(event.target).data('id'));
        console.log(
            "upc:", App.upc7,
            "/ check:", App.check,
            "/ caller:", App.metamaskAccountID
        );

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.checkItem(
                App.upc7,
                App.check,
                {from: App.metamaskAccountID}
            );
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('checkItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    payItem: function (event) {
        event.preventDefault();
        //var processId = parseInt($(event.target).data('id'));
        console.log(
            "upc:", App.upc8,
            "/ caller:", App.metamaskAccountID
        );

        App.contracts.SupplyChain.deployed().then(function(instance) {
            const walletValue = web3.toWei(App.amountPay, "ether");
            return instance.payItem(
                App.upc8,
                {from: App.metamaskAccountID, value: walletValue}
            );
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('payItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    handOverItem: function (event) {
        event.preventDefault();
        //var processId = parseInt($(event.target).data('id'));
        console.log(
            "upc:", App.upc9,
            "/ caller:", App.metamaskAccountID
        );

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.handOverItem(
                App.upc9,
                {from: App.metamaskAccountID}
            );
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('handOverItem',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    fetchItem: function () {
    ///   event.preventDefault();
    ///   var processId = parseInt($(event.target).data('id'));
        //App.upc = $('#upc').val();
        console.log('upc',App.upc);

        App.contracts.SupplyChain.deployed().then(function(instance) {
          return instance.fetchItemBufferOne(App.upc);
        }).then(function(result) {
          $("#ftc-fetchData1").text(result);
          console.log('fetchItemBufferOne', result);
        }).catch(function(err) {
          console.log(err.message);
        });
        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.fetchItemBufferTwo.call(App.upc);
          }).then(function(result) {
            $("#ftc-fetchData2").text(result);
            console.log('fetchItemBufferTwo', result);
          }).catch(function(err) {
            console.log(err.message);
        });
        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.fetchItemBufferThree.call(App.upc);
        }).then(function(result) {
            $("#ftc-fetchData3").text(result);
            console.log('fetchItemBufferThree', result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    addSupplier: function (event) {
        event.preventDefault();
        //var processId = parseInt($(event.target).data('id'));
        console.log(
            "address:", App.address,
        );

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.addSupplier(
                App.address,
                {from: App.metamaskAccountID}
            );
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('addSupplier',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    addContractor: function (event) {
        event.preventDefault();
        //var processId = parseInt($(event.target).data('id'));
        console.log(
            "address:", App.address,
        );

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.addContractor(
                App.address,
                {from: App.metamaskAccountID}
            );
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('addContractor',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    addCustomer: function (event) {
        event.preventDefault();
        //var processId = parseInt($(event.target).data('id'));
        console.log(
            "address:", App.address,
        );

        App.contracts.SupplyChain.deployed().then(function(instance) {
            return instance.addCustomer(
                App.address,
                {from: App.metamaskAccountID}
            );
        }).then(function(result) {
            $("#ftc-item").text(result);
            console.log('addCustomer',result);
        }).catch(function(err) {
            console.log(err.message);
        });
    },

    fetchEvents: function () {
        if (typeof App.contracts.SupplyChain.currentProvider.sendAsync !== "function") {
            App.contracts.SupplyChain.currentProvider.sendAsync = function () {
                return App.contracts.SupplyChain.currentProvider.send.apply(
                App.contracts.SupplyChain.currentProvider,
                    arguments
              );
            };
        }

        App.contracts.SupplyChain.deployed().then(function(instance) {
        var events = instance.allEvents(function(err, log){
          if (!err)
            $("#ftc-events").append('<li>' + log.event + ' - ' + log.transactionHash + '</li>');
        });
        }).catch(function(err) {
          console.log(err.message);
        });

    }
};

// calls App.init()
$(function () {
    $(window).load(function () {
        App.init();
    });
});