public class SCHCalcultorCtrl{
    
    // Variables: Schedule Modifiers - Internal Procedures (-5% to +10%):
    
    public Integer docketSystems            {get; set;}
    public Integer conflictSystems          {get; set;}
    public Integer clientInatke             {get; set;}
    public Integer billProcedure            {get; set;}
    public Integer feeSuits                 {get; set;}
    public Integer outsideInterests         {get; set;}
    public Integer mgmtCommittee            {get; set;}
    public Integer useOfClientEnagagement   {get; set;}
    public Integer useOfClientFeeAgreement  {get; set;}
    public Integer useOfDeclination         {get; set;}
    public Integer useOfTermination         {get; set;}
    public Integer useOfReferral            {get; set;}
    public Integer useOfSettlement          {get; set;}
    public Integer useOfClientCommunication {get; set;}
    public Integer generalOverride          {get; set;}
    
    public Boolean isDocketSystems            {get; set;}
    public Boolean isConflictSystems          {get; set;}
    public Boolean isClientInatke             {get; set;}
    public Boolean isBillProcedure            {get; set;}
    public Boolean isFeeSuits                 {get; set;}
    public Boolean isOutsideInterests         {get; set;}
    public Boolean isMgmtCommittee            {get; set;}
    public Boolean isUseOfClientEnagagement   {get; set;}
    public Boolean isUseOfClientFeeAgreement  {get; set;}
    public Boolean isUseOfDeclination         {get; set;}
    public Boolean isUseOfTermination         {get; set;}
    public Boolean isUseOfReferral            {get; set;}
    public Boolean isUseOfSettlement          {get; set;}
    public Boolean isUseOfClientCommunication {get; set;}
    public Boolean isGeneralOverride          {get; set;}
    
    public List<modWrapper> modWrapList {get; set;}
    public List<modVarWrapper> modVarWrapList {get; set;}
    
    public SCHCalcultorCtrl(){
        
        docketSystems            = 0;
        conflictSystems          = 0;
        clientInatke             = 0;
        billProcedure            = 0;
        feeSuits                 = 0;
        outsideInterests         = 0;
        mgmtCommittee            = 0;
        useOfClientEnagagement   = 0;
        useOfClientFeeAgreement  = 0;
        useOfDeclination         = 0;
        useOfTermination         = 0;
        useOfReferral            = 0;
        useOfSettlement          = 0;
        useOfClientCommunication = 0;
        generalOverride          = 0;
        
        modWrapList = new List<modWrapper>();
        modWrapper mWrap = new modWrapper();
        
        modVarWrapList = new List<modVarWrapper>();
        
        List<String> schModsList = new List<String>{
                                            'Docket Systems',
                                            'Conflict Systems',
                                            'Client Intake/New Matter Acceptance Procedures',
                                            'Billing Procedures',
                                            'Fee Suits',
                                            'Risk Management - Outside Interests',
                                            'Risk Management - Mgmt. Committee',
                                            'Use of Client Engagement/Contingency Fee Agreement Letters'
        };
        
        for(String label: schModsList){
        
            modVarWrapper mVarWrap = new modVarWrapper();
            mVarWrap.label = label;
            mVarWrap.normalMod = 0;
            mVarWrap.overrideMod = 0;
            mVarWrap.isOverride = false;
            modVarWrapList.add(mVarWrap);
        
        }
        
        /*
        modVarWrapper mVarWrap = new modVarWrapper();
        mVarWrap.label = 'Docket Systems';
        mVarWrap.normalMod = 0;
        mVarWrap.overrideMod = 0;
        mVarWrap.isOverride = false;
        
        
        mWrap.modWrapMap = new Map<String, modVarWrapper>{
                                    'Docket Systems' => mVarWrap 
        };
        
        
        */
    
    }
    
    public void calculateMod(){
         Integer schModTotal = 0;
         for(modVarWrapper modVar: modVarWrapList){
             schModTotal = modVar.isOverride ? (modVar.overrideMod == null ? 0 : modVar.overrideMod) : (modVar.normalMod == null ? 0 : modVar.normalMod);
         }
         
         Decimal actualModValue = 0;
         
         if(schModTotal == -100){
             actualModValue = 0;
         } 
         else if(schModTotal == 25){
             actualModValue = 1.25;
         }
         else{
             if(schModTotal < 0){
                 actualModValue = 100 - schModTotal / 100;
             }
             else{
                 actualModValue = schModTotal / 100;
             }
         } 
         
         System.debug('actualModValue----'+actualModValue);
         
    }
    
    
    public class modWrapper{
        public Map<String, modVarWrapper> modWrapMap    {get; set;}     
    }
    
    public class modVarWrapper{
        public String label        {get; set;}       
        public Integer normalMod    {get; set;}
        public Integer overrideMod  {get; set;}
        public Boolean isOverride   {get; set;}
    }
    
}