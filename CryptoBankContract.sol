//SPDX-License-Identifier: GPL-3.0
pragma solidity >=0.7.0 <0.9.0;

contract Bank
{
    address payable Owner;
    struct User
    {
        uint Balance ;
        uint Date ;
    } 

    struct LoanDetails
    {
        uint OutstandingLoan;
        uint MonthlyEmi;
        uint NumberOfEMI;
        uint Date ;  
    }

    mapping(address => User) private  Users;
    mapping(address => LoanDetails) private  PersonalLoan;
    mapping(address => LoanDetails) private  HomeLoan;
    mapping(address => LoanDetails) private  CarLoan;
    mapping (address => uint) private  LoanAmount;
    // mapping(address => mapping(address => uint)) public _allow;


    constructor()
    {
        Owner = payable(msg.sender);
    }


    function Addfund() public payable
    {
        require(msg.value!=0,"Value Should be Greater than Zero");
        require(msg.sender == Owner,"Only Owner can Deposit Funds In Contract");
    }


    function BankBalance() public view returns(uint)
    {
        return address(this).balance;
    }


    function Deposit() public payable
    {
        require( msg.value > 0,"Deposit Fund must be greater than Zero");
        User memory Detail = Users[msg.sender];
        
        Detail.Balance += msg.value;
        Detail.Date  = block.timestamp;

        Users[msg.sender] = Detail;

    }

    function Withdraw(uint amount) public 
    {
        require(msg.sender != address(0),"Receiver can not be zero address");
        require(address(this).balance >= amount, "Insufficient contract balance");
        User memory Detail = Users[msg.sender];
        Detail.Balance -= amount;
        payable(msg.sender).transfer(amount);

        Users[msg.sender] = Detail;
    }



    function GetPersonalLoan(uint amount , uint duration) public payable 
    {
        uint Bblc = address(this).balance;

        require(Users[msg.sender].Balance > 0,"Acount not created yet");
        require(duration>=1,"Duration should be 1 Month or more");
        require(amount>0 && amount<Bblc,"Amount Shuld not be Zero And Less than ContractBalance");

        uint intrest = amount*14/100;

        LoanAmount[msg.sender] = amount;

        LoanDetails memory person  = PersonalLoan[msg.sender];

        User memory Detail = Users[msg.sender];

        person.OutstandingLoan +=  amount +  intrest;
        person.MonthlyEmi += person.OutstandingLoan/duration;
        person.NumberOfEMI += duration;
        
        payable(msg.sender).transfer(amount);
        Bblc = Bblc-amount; 
        Detail.Balance += amount;
        person.Date = block.timestamp;

        Users[msg.sender] = Detail;
        PersonalLoan[msg.sender] = person;

    }

    function GetCarLoan(uint amount, uint duration) public payable
    {
        uint Bblc = address(this).balance;

        require(Users[msg.sender].Balance > 0,"Acount not created yet");
        require(duration>=1,"Duration should be 1 Month or more");
        require(amount>0 && amount<Bblc,"Amount Shuld not be Zero And Less than ContractBalance");

        uint intrest = amount*9/100;

        LoanAmount[msg.sender] = amount;

        LoanDetails memory person = CarLoan[msg.sender];
        User memory Detail = Users[msg.sender];

        person.OutstandingLoan += amount + intrest;
        person.MonthlyEmi += person.OutstandingLoan/duration;
        person.NumberOfEMI  += duration;

        payable(msg.sender).transfer(amount);
        Bblc = Bblc - amount;
        Detail.Balance += amount;
        person.Date = block.timestamp;

        Users[msg.sender] = Detail;
        CarLoan[msg.sender] = person;

    }

    function GetHomeLoan(uint amount , uint duration) public payable
    {
        uint Bblc = address(this).balance;

        require(Users[msg.sender].Balance > 0,"Acount not created yet");
        require(duration>=1,"Duration should be 1 Month or more");
        require(amount>0 && amount<Bblc,"Amount Shuld not be Zero And Less than ContractBalance");

        uint intrest = amount*7/100;

        LoanAmount[msg.sender] = amount;

        // require( Accept(msg.sender),"Waiting for Bank Approval");

        LoanDetails memory person = HomeLoan[msg.sender];
        User memory Detail = Users[msg.sender];

        person.OutstandingLoan += amount + intrest;
        person.MonthlyEmi += person.OutstandingLoan/duration;
        person.NumberOfEMI += duration;

        payable(msg.sender).transfer(amount);
        Bblc = Bblc - amount;
        Detail.Balance += amount;
        person.Date = block.timestamp;

        Users[msg.sender] = Detail;
        HomeLoan[msg.sender] = person;

    }

    // function Accept(address _User) public returns (bool success)
    // {
    //     require(msg.sender == Owner,"Only Owner can Accept");
    //    _allow[Owner][_User] = LoanAmount[_User];

    //    return true;
    // }

    function PersonalLoanDetails(address AccountAddress) public view returns (uint , uint , uint , uint)
    {
        require(msg.sender == Owner || msg.sender == AccountAddress,"Only Bank Owner or Account Holder Can see the details");

        return (PersonalLoan[AccountAddress].OutstandingLoan,
        PersonalLoan[AccountAddress].MonthlyEmi,
        PersonalLoan[AccountAddress].NumberOfEMI,
        PersonalLoan[AccountAddress].Date
        );
    }

    function HomeLoanDetails(address AccountAddress) public view returns (uint , uint , uint , uint)
      {
        require(msg.sender == Owner || msg.sender == AccountAddress,"Only Bank Owner or Account Holder Can see the details");

        return (HomeLoan[AccountAddress].OutstandingLoan,
        HomeLoan[AccountAddress].MonthlyEmi,
        HomeLoan[AccountAddress].NumberOfEMI,
        HomeLoan[AccountAddress].Date
        );
      }

    function CarLoanDetails(address AccountAddress) public view returns (uint , uint , uint , uint)
    {
        require(msg.sender == Owner || msg.sender == AccountAddress,"Only Bank Owner or Account Holder Can see the details");

        return (CarLoan[AccountAddress].OutstandingLoan,
        CarLoan[AccountAddress].MonthlyEmi,
        CarLoan[AccountAddress].NumberOfEMI,
        CarLoan[AccountAddress].Date
        );
    }

    function UserDetails(address AccountAddress) public  view  returns (uint , uint)
    {
        require(msg.sender == Owner || msg.sender == AccountAddress,"Only Bank Owner or Account Holder Can see the details");
        return (Users[AccountAddress].Balance,
        Users[AccountAddress].Date);
    }


    function PayEMI(string memory LoanType) public payable 
    {

        require(msg.value != 0, "Amount can not be Zero");

        if(keccak256(abi.encodePacked(LoanType)) == keccak256(abi.encodePacked("Personal")))
        {
            require(keccak256(abi.encodePacked(LoanType)) == keccak256(abi.encodePacked("Personal")),"Invalid Loan Type");
            require(msg.value == PersonalLoan[msg.sender].MonthlyEmi,"EMI must be equal to due amount");
             
            LoanDetails memory person  = PersonalLoan[msg.sender];
            User memory Detail = Users[msg.sender];

            person.OutstandingLoan -=  msg.value;
            person.NumberOfEMI -= 1;

            Detail.Balance -= msg.value;

            Users[msg.sender] = Detail;
            PersonalLoan[msg.sender] = person;
        }


        if(keccak256(abi.encodePacked(LoanType)) == keccak256(abi.encodePacked("Car")))
        {
            require(keccak256(abi.encodePacked(LoanType)) == keccak256(abi.encodePacked("Car")));
            require(msg.value == CarLoan[msg.sender].MonthlyEmi,"EMI must be equal to due amount");

            LoanDetails memory person  = CarLoan[msg.sender];
            User memory Detail = Users[msg.sender];
            
            person.OutstandingLoan -= msg.value;
            person.NumberOfEMI -= 1;

            Detail.Balance -= msg.value;

            Users[msg.sender] = Detail;
            CarLoan[msg.sender] = person;

        }

        if(keccak256(abi.encodePacked(LoanType)) == keccak256(abi.encodePacked("Home")))
        {
            require(keccak256(abi.encodePacked(LoanType)) == keccak256(abi.encodePacked("Home")));
            require(msg.value == HomeLoan[msg.sender].MonthlyEmi,"EMI must be equal to due amount");
             
            LoanDetails memory person  = HomeLoan[msg.sender];
            User memory Detail = Users[msg.sender];


            person.OutstandingLoan -= msg.value;
            person.NumberOfEMI -= 1;

            Detail.Balance -= msg.value;

            Users[msg.sender] = Detail;
            HomeLoan[msg.sender] = person;
        }


    }


}