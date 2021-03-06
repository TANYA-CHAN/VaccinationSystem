pragma solidity ^0.4.6;

contract Vaccination_System {
    struct Hospital {
        uint id;
        string vaccine;
        uint stock;
        string PrivateKey;
        bool value;
    }

    struct Citizen {
        uint id;
        string name;
        string vaccine;
        bool vaccinated;
        uint doses;
        uint priority;
    }
    
    struct HealthRecord {
        uint id;
        bool pregnant;
        bool seniorcitizen;
        bool vulnerable;
    }
    
    struct Vaccine{
        uint id;
        string name;
        string sideeffect1;
        string sideeffect2;
    }
    
    struct cert_details{
        string CitizenName;
        string PublicKey;
        string Hash;
    }
    mapping(uint => Hospital) private hospital_arr;
    mapping(uint => Citizen) private citizen_arr;
    mapping(uint => HealthRecord) private healthrecord_arr;
    mapping(uint => Vaccine) private vaccine_arr;
    mapping(address => cert_details) certificates;
    event LogHospital (uint indexed id, string vaccine, uint stock, string PrivateKey);
    event LogCitizen (uint indexed id, string name, string vaccine, bool vaccinated, uint doses, uint priority);
    event LogHR (uint indexed id, bool pregnant, bool seniorcitizen, bool vulnerable);
    event LogVaccine (uint indexed id, string name, string sideeffect1, string sideeffect2);
    
    //IMPORTING DATASET
    function InsertHospital(uint id, string vaccine, uint stock, string PrivateKey) public {
        hospital_arr[id].id = id;
        hospital_arr[id].vaccine = vaccine;
        hospital_arr[id].stock = stock;
        hospital_arr[id].PrivateKey = PrivateKey;
        emit LogHospital (id, vaccine, stock, PrivateKey);
    }
    function InsertCitizen(uint id, string name, string vaccine, bool vaccinated, uint doses) public {
        citizen_arr[id].id = id;
        citizen_arr[id].name = name;
        citizen_arr[id].vaccine = vaccine;
        citizen_arr[id].vaccinated = vaccinated;
        citizen_arr[id].doses = doses;
        citizen_arr[id].priority = 0;
        emit LogCitizen(id, name, vaccine, vaccinated, doses, citizen_arr[id].priority);
    }
    function InsertHR(uint id, bool pregnant, bool seniorcitizen, bool vulnerable) public {
        healthrecord_arr[id].id = id;
        healthrecord_arr[id].pregnant = pregnant;
        healthrecord_arr[id].seniorcitizen = seniorcitizen;
        healthrecord_arr[id].vulnerable = vulnerable;
        emit LogHR (id, pregnant, seniorcitizen, vulnerable);
    }
    function InsertVaccine(uint id, string name, string sideeffect1, string sideeffect2) public {
        vaccine_arr[id].id = id;
        vaccine_arr[id].name = name;
        vaccine_arr[id].sideeffect1 = sideeffect1;
        vaccine_arr[id].sideeffect2 = sideeffect2;
        emit LogVaccine (id, name, sideeffect1, sideeffect2);
    }
    
    //ADMINISTRATION
    function vaccinateCitizen(uint c_id, uint h_id) public {
        citizen_arr[c_id].vaccine = hospital_arr[h_id].vaccine;
        citizen_arr[c_id].doses += 1;
        hospital_arr[h_id].stock -= 1;
        if(citizen_arr[c_id].doses == 2){
            citizen_arr[c_id].vaccinated = true;
        }
        emit LogHospital (hospital_arr[h_id].id, hospital_arr[h_id].vaccine, hospital_arr[h_id].stock, hospital_arr[h_id].PrivateKey);
        emit LogCitizen(citizen_arr[c_id].id, citizen_arr[c_id].name, citizen_arr[c_id].vaccine, citizen_arr[c_id].vaccinated, citizen_arr[c_id].doses, citizen_arr[c_id].priority);
    }
    
    //HEALTH RECORDS
    function PrioritizeVaccinate(uint c_id, uint h_id) public {
        while(citizen_arr[c_id].id == healthrecord_arr[h_id].id){
            if(healthrecord_arr[h_id].pregnant || healthrecord_arr[h_id].seniorcitizen || healthrecord_arr[h_id].vulnerable){
                citizen_arr[c_id].priority = 1;
            }
            else{
                    citizen_arr[c_id].priority = 2;
                
            }
        }
        emit LogCitizen(citizen_arr[c_id].id, citizen_arr[c_id].name, citizen_arr[c_id].vaccine, citizen_arr[c_id].vaccinated, citizen_arr[c_id].doses, citizen_arr[c_id].priority);
    }
    
    //SIDE EFFECTS REPORTING
    function report(uint c_id, uint v_id, string memory se) public {
        require(citizen_arr[c_id].doses > 0, "You have not been vaccinated yet");
        if(citizen_arr[c_id].doses == 1){
            vaccine_arr[v_id].sideeffect1 = se;
        }
        else{
            vaccine_arr[v_id].sideeffect2 = se;
        }
        emit LogVaccine (vaccine_arr[v_id].id, vaccine_arr[v_id].name, vaccine_arr[v_id].sideeffect1, vaccine_arr[v_id].sideeffect2);
        
    }
    
    //CERTIFICATE
    address owner;
    constructor() public {
        owner = msg.sender;
    }
    modifier ownerOnly{
        require(owner == msg.sender);
        _;
    }
    function checkHos(uint Hos) view public returns (bool){
        return hospital_arr[Hos].value;
    }
    
    function viewcert(address sender) view public returns(string memory CCitizenName){
        return certificates[sender].CitizenName;
    }
    
    function addcert(string memory PublicKey,string memory CitizenName,string memory Hash, uint hid) public{
        if(checkHos(hid)){
           certificates[msg.sender] = cert_details(CitizenName,PublicKey,Hash);
        }
    }
    function callKeccak256() public pure returns(bytes32 result){
      return keccak256("ABC");
    } 
    
    //TEST ONLY
    function get_h(uint hospitalID) public view returns (uint, string memory, uint){
        return (hospital_arr[hospitalID].id, hospital_arr[hospitalID].vaccine, hospital_arr[hospitalID].stock);
    }
    
    function get_c(uint citizenID) public view returns (uint, string memory, bool, uint){
        return (citizen_arr[citizenID].id, citizen_arr[citizenID].name, citizen_arr[citizenID].vaccinated, citizen_arr[citizenID].doses);
    }
    
    function get_v(uint vid) public view returns (uint, string memory, string memory, string memory){
        return (vaccine_arr[vid].id, vaccine_arr[vid].name, vaccine_arr[vid].sideeffect1, vaccine_arr[vid].sideeffect2);
    }
}
