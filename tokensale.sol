pragma solidity ^0.5.12;

import "./IBEP20.sol";
import "./SafeMath.sol";
import "./Ownable.sol";
import "./Aggregator.sol";


contract PLAS_tokensale is Ownable {
    
    IBEP20 public BEP20Interfaces;
    IBEP20 public BUSDInterfaces;
    AggregatorV3Interface internal priceFeed;
    
    using SafeMath for uint256;
    uint256 SEEDBALANCE = 73e23; // 
    uint256 PRIVATESALEBALANCE = 2e24; // 
    uint256 PRESALEBALANCE = 2e24; //
    uint256 SEEDSOLD = 0;
    uint256 PRIVATESOLD = 0;
    uint256 PRESALESOLD = 0;
    uint256 PRIVATESALEPRICE = 375e15;
    uint256 PRESALEPRICE = 6e17;
    address payable  fund = 0xae9395282d8b07cCE61e5Cb86e3D2599e8a94D52;
    address payable  team = 0xdA09eAee52c9c38c687FB273ca88EAd1d184FE08;
    address payable  treasury = 0xE0F8FEbE7a8DC1B3471Ea6b3C7806591b9feDC16;
    uint256 OPENTIME = 0;
    uint256 ROUNDS = 0 ;
    uint256 public TEAMBALANCE = 45e23;
    uint256 public TEAMWITHDRAWN = 0;
    
    constructor(IBEP20 _PLASaddress, IBEP20 _BUSDaddress)public {
        
        _users[msg.sender].exist = true;
        _users[msg.sender].addr = msg.sender;
        
        BEP20Interfaces = _PLASaddress;
        BUSDInterfaces = _BUSDaddress;
        
        priceFeed = AggregatorV3Interface(0x0567F2323251f0Aab15c8dFb1967E4e8A7D42aeE); //BNB/USD
       
       seedlocktimes.push(seedlocktime(120 days,10));
       seedlocktimes.push(seedlocktime(300 days, 20));
       seedlocktimes.push(seedlocktime(360 days, 30));
       seedlocktimes.push(seedlocktime(420 days, 40));
       seedlocktimes.push(seedlocktime(480 days, 50));
       seedlocktimes.push(seedlocktime(540 days, 60));
       seedlocktimes.push(seedlocktime(600 days, 70));
       seedlocktimes.push(seedlocktime(660 days, 80));
       seedlocktimes.push(seedlocktime(720 days, 90));
       seedlocktimes.push(seedlocktime(780 days, 100));
       
       seedlocktimes2.push(seedlocktime2(360 days,20));
       seedlocktimes2.push(seedlocktime2(450 days, 40));
       seedlocktimes2.push(seedlocktime2(570 days, 60));
       seedlocktimes2.push(seedlocktime2(690 days, 80));
       seedlocktimes2.push(seedlocktime2(780 days, 100));
       
       teamlocktimes.push(teamlocktime(150 days, 10));
       teamlocktimes.push(teamlocktime(210 days, 20));
       teamlocktimes.push(teamlocktime(330 days, 30));
       teamlocktimes.push(teamlocktime(390 days, 40));
       teamlocktimes.push(teamlocktime(450 days, 50));
       teamlocktimes.push(teamlocktime(510 days, 70));
       teamlocktimes.push(teamlocktime(570 days, 80));
       teamlocktimes.push(teamlocktime(630 days, 90));
       teamlocktimes.push(teamlocktime(690 days, 100));
       
       privatelocktimes.push(privatelocktime(150 days, 25));
       privatelocktimes.push(privatelocktime(210 days, 50));
       privatelocktimes.push(privatelocktime(270 days, 75));
       privatelocktimes.push(privatelocktime(330 days, 100));
       
    }
    
    struct User {
        bool exist;
        address addr;
        uint256 PLAS_seed;
        uint256 PLAS_seed2;
        uint256 PLAS_pre;
        uint256 PLAS_priv;
        uint256 Seed_withdrawn;
        uint256 Seed2_withdrawn;
        uint256 Pre_withdrawn;
        uint256 Priv_withdrawn;
    }
    
    struct seedlocktime {
        uint256 day;
        uint256 percent; //div 100
    }
    struct seedlocktime2 {
        uint256 day;
        uint256 percent; //div 100
    }
    struct teamlocktime {
        uint256 day;
        uint256 percent; //div 100
    }
    struct privatelocktime {
        uint256 day;
        uint256 percent; //div 100
    }
    struct whitelist {
        bool eligible;
    }
    struct ai {
        bool investor;
    }
    
    mapping(address => User) private _users;
    mapping(address => whitelist) public _whitelist;
    mapping(address => ai) public _ai;
    seedlocktime[] public seedlocktimes;
    seedlocktime2[] public seedlocktimes2;
    teamlocktime[] public teamlocktimes;
    privatelocktime[] public   privatelocktimes;
    
    event Purchase(address indexed _addr,string _type,uint256 _amount);
    event Withdraw(address indexed _addr, uint256 _amount,bool _private);
    event Withdrawseed(address indexed _addr, uint256 _amount);
    event Withdrawteam(address indexed _addr, uint256 _amount);
    event WithdrawFund(uint256 _bnb, uint256 _busd);
    
    function addseed(address _seed,uint256 _type)public onlyOwner returns(bool){
        require(_seed != owner(),"Owner can't purchase");
        require(ROUNDS > 0,"Rounds not open");
        uint256 _amt = SEEDBALANCE.div(10);
        require(_amt.add(SEEDSOLD) <= SEEDBALANCE, "Msg :: Token Sold out");
        _users[_seed].exist = true;
        _users[_seed].addr = _seed;
        if(_type > 0 ){
            _addtoken(_seed,0,_amt,0,0);
        }else{
            _addtoken(_seed,_amt,0,0,0);
        }
        SEEDSOLD = SEEDSOLD.add(_amt);
        _ai[_seed].investor = true;
        return true;
    }
    
    function addwl(address[] memory _wl,bool _elg)public onlyOwner returns(bool){
        uint8 i = 0;
        for (i; i < _wl.length; i++) {
             _whitelist[_wl[i]].eligible=_elg;
        }
        return true;
    }
    
    function opentime()public onlyOwner returns(bool){
        if(OPENTIME==0){
        OPENTIME = block.timestamp;
        }
        return true;
    } 
    
    function BNBPrice() public view returns (uint256){
        return getThePrice();
    }
    
    function getThePrice() internal view returns (uint256) {
        return  priceFeed.latestAnswer();
    }
    
    function changeround() public onlyOwner returns (uint256 _currentrounds) {
        require(ROUNDS<4,"Can't Change Rounds");
        ROUNDS = ROUNDS.add(1);
        return ROUNDS;
    }
    
    function purchase( bool _privatesale, bool _withbusd, uint256 _buyamount) external payable returns(bool){
        require(msg.sender != owner(),"Owner can't purchase");
        bool seedinvestor = _ai[msg.sender].investor;
        require(seedinvestor==false,"You are seedinvestor, not eligible to buy tokensale");
        uint256 TokenAmount = 0;
        uint256 BuyAmount = 0;
        if(_withbusd){
            uint256 _allowance = BUSDInterfaces.allowance(msg.sender, address(this));
            require(_allowance > 0, "Msg :: Please approve token first");
            BuyAmount = _buyamount;
            BUSDInterfaces.transferFrom(msg.sender, address(this), BuyAmount);
            
        }else{
            BuyAmount = msg.value.mul(getThePrice()).div(1e8);
        }
        
        if(_privatesale){
            require(ROUNDS == 2,"Rounds not open");
            bool eligible = _whitelist[msg.sender].eligible;
            require(eligible,"You are not eligible to buy privatesale");
            uint256 minamount = 20000e18;
            uint256 tolerance = 50e18; //tolerance 50$ if bnbprice was change.
            require(BuyAmount >= (minamount.sub(tolerance)), "Msg :: minimum purchase amount is not enough for Private Sale");
            TokenAmount = BuyAmount.mul(1e18).div(PRIVATESALEPRICE);
            require(TokenAmount.add(PRIVATESOLD) <= PRIVATESALEBALANCE, "Msg :: Token Sold out");
            _addtoken(msg.sender,0,0,TokenAmount,0);
            PRIVATESOLD = PRIVATESOLD.add(TokenAmount);
        }else{
            //for presale not public sale
            require(ROUNDS == 3,"Rounds not open");
            uint256 minamount = 500e18;
            uint256 tolerance = 5e18; //tolerance 5$
            require(BuyAmount >= minamount.sub(tolerance), "Msg :: minimum purchase amount is not enough for Pre Sale");
            TokenAmount = BuyAmount.mul(1e18).div(PRESALEPRICE);
            require(TokenAmount.add(PRESALESOLD) <= PRESALEBALANCE, "Msg :: Token Sold out");
            _addtoken(msg.sender,0,0,0,TokenAmount);
            PRESALESOLD = PRESALESOLD.add(TokenAmount);
        }
        
        return true;
    }
    
    function _addtoken(address _addr,uint256 _seed,uint256 _seed2,uint256 _private,uint256 _pre) private {
        
        _users[_addr].PLAS_seed = _users[_addr].PLAS_seed.add(_seed);
        _users[_addr].PLAS_seed2 =  _users[_addr].PLAS_seed2.add(_seed2);
        _users[_addr].PLAS_priv = _users[_addr].PLAS_priv.add(_private);
        _users[_addr].PLAS_pre = _users[_addr].PLAS_pre.add(_pre);
        
        if(_private>0){
            emit Purchase(_addr,'Private Sale',_private);
        }else if(_seed>0 || _seed2>0){
            uint seedamt = _seed > 0 ? _seed : _seed2;
            emit Purchase(_addr,'Seed Sale',seedamt);
        }else{
            emit Purchase(_addr,'Pre Sale',_pre);
        }
            
    }
    
    function wd_fund()public onlyOwner returns(bool){
        fund.transfer(address(this).balance);
        uint256 BUSD_balance = BUSDInterfaces.balanceOf(address(this));
        BUSDInterfaces.transfer(fund,BUSD_balance);
        emit WithdrawFund(address(this).balance,BUSD_balance);
        return true;
    }
    
    function wd_PLAS(bool _private) external {
        User storage player = _users[msg.sender];
        uint256 amount = _private == true ? player.PLAS_priv : (player.PLAS_pre).sub(player.Pre_withdrawn);
        if(_private){
        require (OPENTIME>0,"OPENTIME not open");
        (uint256 unlocktime, uint256 unlockpercent) = _privateunlock();
        require(block.timestamp >= OPENTIME.add(unlocktime),"Balance lock");
        uint256 wd_limit = amount.mul(unlockpercent).div(100);
        amount = wd_limit.sub(player.Priv_withdrawn);
        player.Priv_withdrawn = player.Priv_withdrawn.add(amount);
        }else{
        player.Pre_withdrawn = player.Pre_withdrawn.add(amount);   
        }
        require(amount > 0, "Zero Balance or still locked, can't wd");
        BEP20Interfaces.transfer( msg.sender, amount);
        emit Withdraw(msg.sender,amount,_private);
    }
    
    function wd_seed(bool _seed2) external {
        require (OPENTIME>0,"OPENTIME not open");
        User storage player = _users[msg.sender];
        uint256 amount = _seed2 == true ? player.PLAS_seed2 : player.PLAS_seed;
        (uint256 unlocktime, uint256 unlockpercent) = _seedunlock(_seed2);
        require(block.timestamp >= OPENTIME.add(unlocktime),"Balance lock");
        uint256 wd_limit = amount.mul(unlockpercent).div(100);
        if(_seed2){
            amount = wd_limit.sub(player.Seed2_withdrawn);
            player.Seed2_withdrawn = player.Seed2_withdrawn.add(amount);
        }else{
            amount = wd_limit.sub(player.Seed_withdrawn);
            player.Seed_withdrawn = player.Seed_withdrawn.add(amount);
        }
        require(amount> 0, "Zero Balance or still locked, can't wd");
        BEP20Interfaces.transfer( msg.sender, amount);
        emit Withdrawseed(msg.sender,amount);
    }
    
    function wd_team() external onlyOwner {
        require (OPENTIME>0,"OPENTIME not open");
        uint256 amount = TEAMBALANCE;
        (uint256 unlocktime, uint256 unlockpercent) = _teamunlock();
        require(block.timestamp >= OPENTIME.add(unlocktime),"Balance lock");
        uint256 wd_limit = amount.mul(unlockpercent).div(100);
        amount = wd_limit.sub(TEAMWITHDRAWN);
        TEAMWITHDRAWN = TEAMWITHDRAWN.add(amount);
        BEP20Interfaces.transfer(team,amount);
        emit Withdrawteam(msg.sender,amount);
    }
    
    function _seedunlock(bool _seed2)internal view returns(uint256,uint256){
        uint256 day = 150 days;
        uint256 percent = 0;
        if(_seed2!=true){
            for(uint256 i = 0; i < seedlocktimes.length; i++) {
                if(block.timestamp > OPENTIME.add(seedlocktimes[i].day)){
                    day = seedlocktimes[i].day;
                    percent = seedlocktimes[i].percent;
                }else{break;}
            }
        }else{
            for(uint256 i = 0; i < seedlocktimes2.length; i++) {
                if(block.timestamp > OPENTIME.add(seedlocktimes2[i].day)){
                    day = seedlocktimes2[i].day;
                    percent = seedlocktimes2[i].percent;
                }else{break;}
            }
        }
        return (day,percent);
    }
    
    function _teamunlock() internal view returns(uint256,uint256){
        uint256 day = 150 days;
        uint256 percent = 0;
        for(uint256 i = 0; i < teamlocktimes.length; i++) {
            if(block.timestamp > OPENTIME.add(teamlocktimes[i].day)){
                day = teamlocktimes[i].day;
                percent = teamlocktimes[i].percent;
            }else{
                break;
            }
        }
        return (day,percent);
    }
    function _privateunlock()internal view returns(uint256,uint256){
        uint256 day = 150 days;
        uint256 percent = 0;
        for(uint256 i = 0; i < privatelocktimes.length; i++) {
            if(block.timestamp > OPENTIME.add(privatelocktimes[i].day)){
                day = privatelocktimes[i].day;
                percent = privatelocktimes[i].percent;
            }else{
                break;
            }
        } 
        return (day,percent);
    }
    
    function remainingtoken()external onlyOwner returns(bool){
        //for the remaining unsold tokens
        require(ROUNDS>3,"Rounds Not Open");
        uint256 amount = PRIVATESALEBALANCE.sub(PRIVATESOLD);
        amount = amount.add(PRESALEBALANCE.sub(PRESALESOLD));
        BEP20Interfaces.transfer(treasury,amount);
        PRIVATESOLD = PRIVATESALEBALANCE;
        PRESALESOLD = PRESALEBALANCE;
        return true;
    }
    
    function userInfo(address _addr) view external returns(bool _exist, uint256 _seedbalance,uint256 _seedbalance2,uint256 _privatebalance,uint256 _presalebalance, uint256 _seedwd,uint256 _seedwd2,uint256 _privatewd, uint256 _presalewd) {
        User storage player = _users[_addr];

        return (
            player.exist,
            player.PLAS_seed.sub(player.Seed_withdrawn),
            player.PLAS_seed2.sub(player.Seed2_withdrawn),
            player.PLAS_priv.sub(player.Priv_withdrawn),
            player.PLAS_pre.sub(player.Pre_withdrawn),
            player.Seed_withdrawn,
            player.Seed2_withdrawn,
            player.Priv_withdrawn,
            player.Pre_withdrawn
        );
    }
     

    function contractInfo() view external returns(
    
    uint256 SEED_BALANCE, 
    uint256 PRESALE_BALANCE, 
    uint256 PRIVATE_BALANCE,    
    uint256 SEED_SOLD,   
    uint256 PRIVATE_SOLD,
    uint256 PRESALE_SOLD,
    uint256 PRIVATESALE_PRICE,
    uint256 PRESALE_PRICE,
    uint256 ROUND,
    uint256 OPENTIME_TIME) {
        return ( 
           SEEDBALANCE,
            PRIVATESALEBALANCE,PRESALEBALANCE,SEEDSOLD ,PRIVATESOLD , PRESALESOLD ,PRIVATESALEPRICE , PRESALEPRICE ,
    ROUNDS , OPENTIME );
    }
   

}