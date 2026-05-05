/*
 * 
 * Created By     : Ali Zaidi
 * Created Date   : 12/09/2016
 * Purpose        : This class provides extension for the CloneMasterFactorWithChildsVFP.
 * Name           : CloneMasterFactorWithChilds
 * Referenced     : Currently at the time of creation this class is referenced by CloneMasterFactorWithChildsVFP.
 * 
 *  
 */
public class CloneMasterFactorWithChilds {
    private final String currentMasterFactorId;
    private Master_Factor__c masterFactor;
    public Master_Factor__c cloneFactor {get; set;}
        
    public CloneMasterFactorWithChilds (ApexPages.StandardController stdController) {
        currentMasterFactorId = (String)stdController.getRecord().Id;
        //masterFactor = [SELECT Id, Name, Cloned_From__c, Factor_Type__c, From_Date__c, To_Date__c FROM Master_Factor__c WHERE Id =: currentMasterFactorId];
        Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Master_Factor__c').getDescribe().fields.getMap();
        List<String> fieldNames = new List<String>(fieldMap.keySet());
        List<Master_Factor__c> masterFactors = (List<Master_Factor__c>)Database.query('SELECT '+String.join(fieldNames, ', ')+' FROM Master_Factor__c WHERE Id =: currentMasterFactorId');
        masterFactor = masterFactors[0];
        cloneFactor = masterFactor.clone(false,true);
        cloneFactor.From_Date__c   = Date.today();
        cloneFactor.To_Date__c     = Date.today().addYears(1);
        cloneFactor.Name           = cloneFactor.Factor_Type__c + ' - ' +  cloneFactor.From_Date__c.day() + '/' + cloneFactor.From_Date__c.month() + '/' + cloneFactor.From_Date__c.year() + ' - ' + cloneFactor.To_Date__c.day() + '/' + cloneFactor.To_Date__c.month() + '/' + cloneFactor.To_Date__c.year();
        cloneFactor.Cloned_From__c = currentMasterFactorId;
    }
    
    public PageReference Save () {
        insert cloneFactor;
        
        if (cloneFactor.Factor_Type__c == 'Coverage') {
            list<ILF_Coverage_Factor__c> clonedCoverage = new list<ILF_Coverage_Factor__c>();
            list<ILF_Coverage_Factor__c> coverageToClone = new list<ILF_Coverage_Factor__c>();
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('ILF_Coverage_Factor__c').getDescribe().fields.getMap();
            List<String> fieldNames = new List<String>(fieldMap.keySet());
            System.debug('index of => '+fieldNames.indexOf('limit_external_id__c'));
            if(fieldNames.indexOf('limit_external_id__c') != -1 ){
                fieldNames.remove(fieldNames.indexOf('limit_external_id__c'));
            }
            coverageToClone = (List<ILF_Coverage_Factor__c>)Database.query('SELECT '+String.join(fieldNames, ', ')+' FROM ILF_Coverage_Factor__c WHERE Master_Factor__c =: currentMasterFactorId');

            //coverageToClone = [SELECT Coverage_Max_Per_Claim__c, Factor_Value__c, Full_Coverage__c, Id, Is_5X5_Coverage__c, Is_10X10_Coverage__c, Is_Excess_Value_Zero__c, Lowest_Coverage__c, Master_Factor__c, Mid_Coverage__c, Name, Percentage_5X5_Step_0__c, Percentage_5X5_Step_1__c, Percentage_5X5_Step_2__c, Percentage_5X5_Step_3__c, Percentage_5X5_Step_4__c, Percentage_5X5_Step_5__c, Percentage_5X5_Step_6__c, Percentage_5X5_Step_7__c, Percnt_amt_5X5_Step_0__c, Percnt_amt_5X5_Step_1__c, Percnt_amt_5X5_Step_2__c, Percnt_amt_5X5_Step_3__c, Percnt_amt_5X5_Step_4__c, Percnt_amt_5X5_Step_5__c, Percnt_amt_5X5_Step_6__c, Percnt_amt_5X5_Step_7__c, Premium_Rate_5X5__c FROM ILF_Coverage_Factor__c WHERE Master_Factor__c =: currentMasterFactorId];
            
            if (coverageToClone.size() > 0) {
                for (ILF_Coverage_Factor__c cov : coverageToClone) {
                    ILF_Coverage_Factor__c newCov = new ILF_Coverage_Factor__c();
                    newCov = cov.clone(false,true);
                    newCov.Master_Factor__c = cloneFactor.Id;
                    clonedCoverage.add(newCov);
                }
                insert clonedCoverage;
            }
        } else if (cloneFactor.Factor_Type__c == 'Deductible') {
            list<Deductible_Factor__c> clonedDeductible = new list<Deductible_Factor__c>();
            list<Deductible_Factor__c> deductibleToClone = new list<Deductible_Factor__c>();
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Deductible_Factor__c').getDescribe().fields.getMap();
            List<String> fieldNames = new List<String>(fieldMap.keySet());
            System.debug('index of => '+fieldNames.indexOf('deductible_external_id__c'));
            if(fieldNames.indexOf('deductible_external_id__c') != -1 ){
                fieldNames.remove(fieldNames.indexOf('deductible_external_id__c'));
            }
            deductibleToClone = (List<Deductible_Factor__c>)Database.query('SELECT '+String.join(fieldNames, ', ')+' FROM Deductible_Factor__c WHERE Master_Factor__c =: currentMasterFactorId');
            //deductibleToClone = [SELECT Deductible_Amount__c, Factor_Value__c, Id, Master_Factor__c, Name FROM Deductible_Factor__c WHERE Master_Factor__c =: currentMasterFactorId];
            
            if (deductibleToClone.size() > 0) {
                for (Deductible_Factor__c ded : deductibleToClone) {
                    Deductible_Factor__c newDed = new Deductible_Factor__c();
                    newDed = ded.clone(false,true);
                    newDed.Master_Factor__c = cloneFactor.Id;
                    clonedDeductible.add(newDed);
                }
                insert clonedDeductible;
            }
        } else if (cloneFactor.Factor_Type__c == 'AOP') {
            list<AOP_Factor__c> clonedAops = new list<AOP_Factor__c>();
            list<AOP_Factor__c> aopsToClone = new list<AOP_Factor__c>();
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('AOP_Factor__c').getDescribe().fields.getMap();
            List<String> fieldNames = new List<String>(fieldMap.keySet());
            System.debug('index of => '+fieldNames.indexOf('aop_external_id__c'));
            if(fieldNames.indexOf('aop_external_id__c') != -1 ){
                fieldNames.remove(fieldNames.indexOf('aop_external_id__c'));
            }
            System.debug('index of => '+fieldNames.indexOf('next_aop_factor__c'));
            if(fieldNames.indexOf('next_aop_factor__c') != -1 ){
                fieldNames.remove(fieldNames.indexOf('next_aop_factor__c'));
            }
            aopsToClone = (List<AOP_Factor__c>)Database.query('SELECT '+String.join(fieldNames, ', ')+' FROM AOP_Factor__c WHERE Master_Factor__c =: currentMasterFactorId');
            //aopsToClone = [SELECT Id, Name, AOP_Mod__c, Law_Area_Category__c, Master_Factor__c FROM AOP_Factor__c WHERE Master_Factor__c =: currentMasterFactorId];
            
            if (aopsToClone.size() > 0) {
                for (AOP_Factor__c aopfactor : aopsToClone) {
                    AOP_Factor__c factor = new AOP_Factor__c();
                    factor = aopFactor.clone(false,true);
                    factor.Master_Factor__c = cloneFactor.Id;
                    clonedAops.add(factor);
                }
                insert clonedAops;
                for(Integer i=0;i<aopsToClone.size();i++){
                    aopsToClone[i].Next_AOP_Factor__c  = clonedAops[i].Id;
                }
                update aopsToClone;
            }
        } else if (cloneFactor.Factor_Type__c == 'Step Rate') {
            list<Step_Rate_Factor__c> clonedStep = new list<Step_Rate_Factor__c>();
            list<Step_Rate_Factor__c> stepsToClone = new list<Step_Rate_Factor__c>();
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Step_Rate_Factor__c').getDescribe().fields.getMap();
            List<String> fieldNames = new List<String>(fieldMap.keySet());
            stepsToClone = (List<Step_Rate_Factor__c>)Database.query('SELECT '+String.join(fieldNames, ', ')+' FROM Step_Rate_Factor__c WHERE Master_Factor__c =: currentMasterFactorId');
            //stepsToClone = [SELECT Factor_Value_Step_Rate_0__c, Factor_Value_Step_Rate_1__c, Factor_Value_Step_Rate_2__c, Factor_Value_Step_Rate_3__c, Factor_Value_Step_Rate_4__c, Factor_Value_Step_Rate_5__c, Factor_Value_Step_Rate_6__c, Factor_Value_Step_Rate_7__c, Id, Master_Factor__c, Name FROM Step_Rate_Factor__c WHERE Master_Factor__c =: currentMasterFactorId];
            
            if (stepsToClone.size() > 0) {
                for (Step_Rate_Factor__c step : stepsToClone) {
                    Step_Rate_Factor__c newStep = new Step_Rate_Factor__c();
                    newStep = step.clone(false,true);
                    newStep.Master_Factor__c = cloneFactor.Id;
                    clonedStep.add(newStep);
                }
                insert clonedStep;
            }
        } else if (cloneFactor.Factor_Type__c == 'Base Value') {
            list<Base_Factor__c> clonedBase = new list<Base_Factor__c>();
            list<Base_factor__c> baseToClone = new list<Base_Factor__c>();
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('Base_Factor__c').getDescribe().fields.getMap();
            List<String> fieldNames = new List<String>(fieldMap.keySet());
            baseToClone = (List<Base_Factor__c>)Database.query('SELECT '+String.join(fieldNames, ', ')+' FROM Base_Factor__c WHERE Master_Factor__c =: currentMasterFactorId');
            //baseToClone = [SELECT Base_Amount__c, Id, Master_Factor__c, Name FROM Base_Factor__c WHERE Master_Factor__c =: currentMasterFactorId];
            
            if (baseToClone.size() > 0) {
                for (Base_Factor__c base : baseToClone) {
                    Base_Factor__c newBase = new Base_Factor__c();
                    newBase = base.clone(false,true);
                    newBase.Master_Factor__c = cloneFactor.Id;
                    clonedBase.add(newBase);
                }
                insert clonedBase;
            }
        } else if (cloneFactor.Factor_Type__c == 'GEO') {
            list<GEO_Factor__c> clonedGeo = new list<GEO_Factor__c>();
            list<GEO_Factor__c> geoToClone = new list<GEO_Factor__c>();
            Map<String, Schema.SObjectField> fieldMap = Schema.getGlobalDescribe().get('GEO_Factor__c').getDescribe().fields.getMap();
            List<String> fieldNames = new List<String>(fieldMap.keySet());
            System.debug('index of => '+fieldNames.indexOf('geo_external_id__c'));
            if(fieldNames.indexOf('geo_external_id__c') != -1 ){
                fieldNames.remove(fieldNames.indexOf('geo_external_id__c'));
            }
            
            geoToClone = (List<GEO_Factor__c>)Database.query('SELECT '+String.join(fieldNames, ', ')+' FROM GEO_Factor__c WHERE Master_Factor__c =: currentMasterFactorId');
            //geoToClone = [SELECT County__c, Id, Master_Factor__c, Name, Region_Code__c, Region_Factor_Value__c FROM GEO_Factor__c WHERE Master_Factor__c =: currentMasterFactorId];
            
            if (geoToClone.size() > 0) {
                for (GEO_Factor__c geo : geoToClone) {
                    GEO_Factor__c newGeo = new GEO_Factor__c();
                    newGeo = geo.clone(false,true);
                    newGeo.Master_Factor__c = cloneFactor.Id;
                    clonedGeo.add(newGeo);
                }
                insert clonedGeo;
            }
        }
        
        PageReference newFactorPage = new PageReference('/' + cloneFactor.Id);
        newFactorPage.setRedirect(true);
        return newFactorPage;
    }
    
    public PageReference Cancel () {
        PageReference cancelPage = new PageReference('/' + currentMasterFactorId);
        cancelPage.setRedirect(true);
        return cancelPage;
    }
}