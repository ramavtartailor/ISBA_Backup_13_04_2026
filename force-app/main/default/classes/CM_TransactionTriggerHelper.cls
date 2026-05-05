/*-********************************************************************************************************
* Name         : CM_TransactionTriggerHelper
* @Author      : Vikram Singh(vikramsingh@cmentor.com)
* @Date        : 01-Mar-2017
* @Description : This apex class does  
* UPDATES
* Version          Developer                    Date                        Description
*-------------------------------------------------------------------------------------------
*     1.0            vikram                       01-Mar-2017                   Initial Creation 
****************************************************************************************************************/

public without sharing class CM_TransactionTriggerHelper{
    
    public static Map<Id,Policy_Claim__c> PolicyClaimMap;
    
    
    
    public CM_TransactionTriggerHelper(){
        
    }
    public static list<AcctSeed__Scheduled_Revenue_Expense__c> createRevenueSchedules(AS_Transaction__c t, map<string,AcctSeed__Accounting_Period__c> mapAccountingPeriod, string GLCredit, string GLDebit){
        return createRevenueSchedules(t, mapAccountingPeriod, GLCredit, GLDebit,null);
    }
    public static list<AcctSeed__Scheduled_Revenue_Expense__c> createRevenueSchedules(AS_Transaction__c t, map<string,AcctSeed__Accounting_Period__c> mapAccountingPeriod, string GLCredit, string GLDebit,Decimal customAmount){
        try{
            
            list<AcctSeed__Scheduled_Revenue_Expense__c> listOfAllSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
            
            Decimal amount = customAmount!=null ? customAmount : t.Amount__c;
            
            if(amount < 0){
                amount *= -1;
            }
            Integer totalDays = t.Policy_Id__r.Effective_Date__c.daysBetween(t.Policy_Id__r.Expiration_Date__c);
            Date scheduleDate = t.Policy_Id__r.Effective_Date__c;
            Date transactionStartDate = t.Policy_Id__r.GL_Processing_Date__c != null ? t.Policy_Id__r.GL_Processing_Date__c :  (t.Policy_Id__r.Effective_Date__c >= System.today() ? t.Policy_Id__r.Effective_Date__c : System.today());
                if(t.Policy_Endorsement_Id__c != null){
                    transactionStartDate = t.Policy_Endorsement_Id__r.GL_Processing_Date__c != null ? t.Policy_Endorsement_Id__r.GL_Processing_Date__c :  (t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c >= System.today() ? t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c : System.today());
                        scheduleDate = t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c;
                    totalDays = t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c.daysBetween(t.Policy_Id__r.Expiration_Date__c);
                }
            transactionStartDate = transactionStartDate.toStartOfMonth().addMonths(1).addDays(-1);
            Date transactionEndDate = t.Policy_Id__r.Expiration_Date__c.addDays(-1).toStartOfMonth().addDays(-1);
            
            
            
            
            Decimal oneDayAmount = amount/totalDays;
            oneDayAmount = oneDayAmount.setscale(2,RoundingMode.FLOOR);
            Decimal temp = amount;
            while(transactionStartDate <= transactionEndDate){
                AcctSeed__Scheduled_Revenue_Expense__c RevenueSchedule = new AcctSeed__Scheduled_Revenue_Expense__c();
                RevenueSchedule.AcctSeed__Amount__c = oneDayAmount * (scheduleDate.daysBetween(transactionStartDate) + 1);
                
                temp -= RevenueSchedule.AcctSeed__Amount__c;
                
                RevenueSchedule.AcctSeed__Quantity__c = 1;
                
                RevenueSchedule.AcctSeed__Credit_GL_Account__c = GLCredit;
                RevenueSchedule.AcctSeed__Debit_GL_Account__c = GLDebit;
                RevenueSchedule.Name = t.Firm_Id__r.Name.subString(0,(t.Firm_Id__r.Name.length() > 70 ? 70 : t.Firm_Id__r.Name.length() )) + '-' + transactionStartDate.year() + '/' + transactionStartDate.month();
                
                string acKey1 = 'key'+transactionStartDate.month()+'year'+transactionStartDate.year();
                if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey1)){
                    RevenueSchedule.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey1).Id;
                }
                RevenueSchedule.AcctSeed__Account2__c = t.Firm_Id__c;
                RevenueSchedule.AS_Transaction__c = t.Id;
                RevenueSchedule.Policy__c = t.Policy_Id__c;
                RevenueSchedule.Date__c = transactionStartDate;
                listOfAllSchedules.add(RevenueSchedule);
                scheduleDate = transactionStartDate.addDays(1);
                transactionStartDate = transactionStartDate.toStartOfMonth().addMonths(2).addDays(-1);
            }
            
            if(t.Policy_Id__r.Expiration_Date__c.addDays(-1) >= scheduleDate){
                AcctSeed__Scheduled_Revenue_Expense__c RevenueSchedule = new AcctSeed__Scheduled_Revenue_Expense__c();
                RevenueSchedule.AcctSeed__Amount__c = temp;
                
                RevenueSchedule.AcctSeed__Quantity__c = 1;
                
                RevenueSchedule.AcctSeed__Credit_GL_Account__c = GLCredit;
                RevenueSchedule.AcctSeed__Debit_GL_Account__c = GLDebit;
                RevenueSchedule.Name = t.Firm_Id__r.Name.subString(0,(t.Firm_Id__r.Name.length() > 70 ? 70 : t.Firm_Id__r.Name.length() )) + '-' + t.Policy_Id__r.Expiration_Date__c.addDays(-1).year() + '/' + t.Policy_Id__r.Expiration_Date__c.addDays(-1).month();
                
                string acKey1 = 'key'+t.Policy_Id__r.Expiration_Date__c.addDays(-1).month()+'year'+t.Policy_Id__r.Expiration_Date__c.addDays(-1).year();
                if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey1)){
                    RevenueSchedule.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey1).Id;
                }
                RevenueSchedule.AcctSeed__Account2__c = t.Firm_Id__c;
                RevenueSchedule.AS_Transaction__c = t.Id;
                RevenueSchedule.Policy__c = t.Policy_Id__c;
                RevenueSchedule.Date__c = t.Policy_Id__r.Expiration_Date__c.addDays(-1);
                listOfAllSchedules.add(RevenueSchedule);
            }
            
            return listOfAllSchedules;
            
            /*integer noOfMonths = 0;
noOfMonths = 12;
system.debug('===policy dates='+t.Policy_Id__r.Expiration_Date__c+ '--'+t.Policy_Id__r.Effective_Date__c);

integer policyStartDay =  t.Policy_Id__r.Effective_Date__c.Day();
integer policyStartMonth = t.Policy_Id__r.Effective_Date__c.month();
integer policyStartYear = t.Policy_Id__r.Effective_Date__c.year();
integer policyEndMonth = t.Policy_Id__r.Expiration_Date__c.month();
integer policyEndYear = t.Policy_Id__r.Expiration_Date__c.year();

//integer currentMonth = date.today().month();
//integer currentYear = date.today().year();
integer currentMonth = policyStartMonth;
integer currentYear = policyStartYear;    


decimal monthlyAmount = amount / noofMonths;

if(monthlyAmount < 0)
monthlyAmount = -(monthlyAmount);

decimal for1day = monthlyAmount / (date.daysInMonth(policyEndYear , policyEndMonth)*12);
system.debug('---monthlyAmount---'+for1day);
monthlyAmount -= for1day;
//Date schDate = date.newInstance(currentYear, currentMonth+1, 1);
Date schDate = date.newInstance(policyStartYear, policyStartMonth+1, 1);
Date endDate = date.newInstance(policyEndYear, policyEndMonth, 1);


decimal tempTotal = amount;

system.debug('=end month ='+policyEndMonth + ' year '+policyEndYear);
decimal amountForCurrentMonth = 0;
if(currentYear > policyStartYear){
if(policyStartMonth < 12){
amountForCurrentMonth = (12-policyStartMonth)*monthlyAmount;
amountForCurrentMonth += (date.daysInMonth(policyStartYear , policyStartMonth) - policyStartDay+ 1)*monthlyAmount/date.daysInMonth(policyStartYear , policyStartMonth);
amountForCurrentMonth += monthlyAmount * currentMonth;              
}
else{
amountForCurrentMonth = monthlyAmount * (currentMonth);
amountForCurrentMonth += (date.daysInMonth(policyStartYear , policyStartMonth) - policyStartDay+ 1)*monthlyAmount/date.daysInMonth(policyStartYear , policyStartMonth);
}
}else if(currentYear == policyStartYear){
amountForCurrentMonth = (monthlyAmount * (currentMonth - policyStartMonth)) +  (date.daysInMonth(policyStartYear , policyStartMonth) - policyStartDay+ 1)*monthlyAmount/date.daysInMonth(policyStartYear , policyStartMonth);

}   

system.debug('===amountForCurrentMonth==='+amountForCurrentMonth);
AcctSeed__Scheduled_Revenue_Expense__c firstRevenueSchedule = new AcctSeed__Scheduled_Revenue_Expense__c();
firstRevenueSchedule.AcctSeed__Amount__c = amountForCurrentMonth.setScale(2, RoundingMode.HALF_UP);

tempTotal -= firstRevenueSchedule.AcctSeed__Amount__c;

firstRevenueSchedule.AcctSeed__Quantity__c = 1;

firstRevenueSchedule.AcctSeed__Credit_GL_Account__c = GLCredit;
firstRevenueSchedule.AcctSeed__Debit_GL_Account__c = GLDebit;
firstRevenueSchedule.Name = t.Firm_Id__r.Name + '-' + currentYear + '/' + currentMonth;

string acKey = 'key'+currentMonth+'year'+currentYear;
if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey)){
firstRevenueSchedule.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey).Id;
}
firstRevenueSchedule.AcctSeed__Account2__c = t.Firm_Id__c;
firstRevenueSchedule.AS_Transaction__c = t.Id;
firstRevenueSchedule.Policy__c = t.Policy_Id__c;
listOfAllSchedules.add(firstRevenueSchedule);

//------for coming months
system.debug('====schDate !!'+schDate+'--endDate '+endDate);
while(schDate < endDate){
system.debug('====inside while loop !!'+schDate);
AcctSeed__Scheduled_Revenue_Expense__c RevenueSchedule = new AcctSeed__Scheduled_Revenue_Expense__c();
RevenueSchedule.AcctSeed__Amount__c = monthlyAmount;

tempTotal -= RevenueSchedule.AcctSeed__Amount__c.setScale(2, RoundingMode.HALF_UP);

RevenueSchedule.AcctSeed__Quantity__c = 1;

RevenueSchedule.AcctSeed__Credit_GL_Account__c = GLCredit;
RevenueSchedule.AcctSeed__Debit_GL_Account__c = GLDebit;
RevenueSchedule.Name = t.Firm_Id__r.Name + '-' + schDate.year() + '/' + schDate.month();

string acKey1 = 'key'+schDate.month()+'year'+schDate.year();
if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey1)){
RevenueSchedule.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey1).Id;
}
RevenueSchedule.AcctSeed__Account2__c = t.Firm_Id__c;
RevenueSchedule.AS_Transaction__c = t.Id;
RevenueSchedule.Policy__c = t.Policy_Id__c;
listOfAllSchedules.add(RevenueSchedule);
schDate = schDate.addMonths(1);
}
if(schDate == endDate){

AcctSeed__Scheduled_Revenue_Expense__c RevenueSchedule = new AcctSeed__Scheduled_Revenue_Expense__c();
RevenueSchedule.AcctSeed__Amount__c = monthlyAmount*(t.Policy_Id__r.Expiration_Date__c.day())/date.daysInMonth(policyEndYear , policyEndMonth);
RevenueSchedule.AcctSeed__Amount__c = RevenueSchedule.AcctSeed__Amount__c;
tempTotal -= RevenueSchedule.AcctSeed__Amount__c;
system.debug('===tempTotal=='+tempTotal);
RevenueSchedule.AcctSeed__Amount__c += tempTotal;
RevenueSchedule.AcctSeed__Amount__c = RevenueSchedule.AcctSeed__Amount__c.setScale(2, RoundingMode.HALF_UP);

RevenueSchedule.AcctSeed__Quantity__c = 1;

RevenueSchedule.AcctSeed__Credit_GL_Account__c = GLCredit;
RevenueSchedule.AcctSeed__Debit_GL_Account__c = GLDebit;
RevenueSchedule.Name = t.Firm_Id__r.Name + '-' + schDate.year() + '/' + schDate.month();

string acKey1 = 'key'+schDate.month()+'year'+schDate.year();
if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey1)){
RevenueSchedule.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey1).Id;
}
RevenueSchedule.AcctSeed__Account2__c = t.Firm_Id__c;
RevenueSchedule.AS_Transaction__c = t.Id;
RevenueSchedule.Policy__c = t.Policy_Id__c;
listOfAllSchedules.add(RevenueSchedule);
}*/
            //system.debug('---listOfAllSchedules---'+listOfAllSchedules);
            
        }   
        catch(exception e){
            system.debug('--exception is a'+e.getMessage()+e.getlinenumber());
            return null;
        }
        
    }
    
    
    public static list<AcctSeed__Scheduled_Revenue_Expense__c> createRevenueSchedulesForComingMonths(AS_Transaction__c t, map<string,AcctSeed__Accounting_Period__c> mapAccountingPeriod, string GLCredit, string GLDebit){
        Date todayDate = Date.today();
        
        
        list<AcctSeed__Scheduled_Revenue_Expense__c> listOfAllSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
        
        
        
        integer policyStartDay =  t.Policy_Id__r.Effective_Date__c.Day();
        integer policyStartMonth = t.Policy_Id__r.Effective_Date__c.month();
        integer policyStartYear = t.Policy_Id__r.Effective_Date__c.year();
        integer policyEndMonth = t.Policy_Id__r.Expiration_Date__c.month();
        integer policyEndYear = t.Policy_Id__r.Expiration_Date__c.year();
        integer policyEndDay = t.Policy_Id__r.Expiration_Date__c.day();
        integer currentMonth = date.today().month();
        integer currentYear = date.today().year();
        system.debug(''+t.Policy_Id__r.Expiration_Date__c);
        system.debug(''+t.createdDate);
        integer noOfMonths = t.Policy_Id__r.Expiration_Date__c.monthsBetween(date.valueOf(t.createdDate));
        system.debug('--noOfMonths are-'+noOfMonths);
        
        integer noOfDays = date.valueOf(t.createdDate).daysBetween(t.Policy_Id__r.Expiration_Date__c);
        //------taking no of months as 12 because
        //noOfMonths = 12;
        decimal transactionAmount = 0;
        decimal monthlyAmount = t.Amount__c / noofMonths;
        if(t.Amount__c < 0){
            
            transactionAmount = -(t.Amount__c);
        }else{
            transactionAmount = t.Amount__c;
        }
        
        
        
        
        //transactionAmount = transactionAmount/noOfMonths;
        system.debug('===transactionAmount==='+noOfDays);
        Date schDate = date.newInstance(currentYear, currentMonth, 1);
        Date endDate = date.newInstance(policyEndYear, policyEndMonth, 1);
        
        
        integer noOfDaysBetweenComingMonthAndExpirationMonth = schDate.addMonths(1).daysBetween(endDate);
        decimal newAmountperDay = (transactionAmount / (noOfDays+1));
        
        integer newNoOfMonthsBetweenComingMonthAndExpirationDate = 0;
        if(schDate.addMonths(1).month() != endDate.month()){
            newNoOfMonthsBetweenComingMonthAndExpirationDate = schDate.addMonths(1).monthsBetween(endDate);
            system.debug('==newNoOfMonthsBetweenComingMonthAndExpirationDate--'+newNoOfMonthsBetweenComingMonthAndExpirationDate);
        }
        decimal newMonthlyAmount = 0;
        if(newNoOfMonthsBetweenComingMonthAndExpirationDate >1){
            newMonthlyAmount = newAmountperDay * noOfDaysBetweenComingMonthAndExpirationMonth / newNoOfMonthsBetweenComingMonthAndExpirationDate;
        }else{
            newMonthlyAmount = newAmountperDay * noOfDaysBetweenComingMonthAndExpirationMonth;
        }
        
        decimal for1day = newMonthlyAmount / (date.daysInMonth(policyEndYear , policyEndMonth)*12);
        system.debug('---transactionAmount---'+for1day);
        // newMonthlyAmount -= for1day;
        
        
        system.debug('=noOfDaysBetweenComingMonthAndExpirationMonth ='+noOfDaysBetweenComingMonthAndExpirationMonth + ' newNoOfMonthsBetweenComingMonthAndExpirationDate '+newNoOfMonthsBetweenComingMonthAndExpirationDate);
        //decimal amountForCurrentMonth = 0;
        
        decimal tempTotal = transactionAmount;
        
        //------for coming months
        system.debug('====schDate !!'+schDate+'--endDate '+endDate);
        while(schDate < endDate){
            system.debug('====inside while loop !!'+schDate);
            AcctSeed__Scheduled_Revenue_Expense__c RevenueSchedule = new AcctSeed__Scheduled_Revenue_Expense__c();
            if(schDate.month() == date.valueOf(t.createdDate).month()){
                //RevenueSchedule.AcctSeed__Amount__c = transactionAmount*(date.daysInMonth(schDate.year(), schDate.month()) - date.valueOf(t.createdDate).day()+1)/date.daysInMonth(schDate.year(), schDate.month());
                decimal temp = (newAmountperDay*(date.daysInMonth(schDate.year(), schDate.month()) - date.valueOf(t.createdDate).day()+1));
                if(temp > newMonthlyAmount){
                    RevenueSchedule.AcctSeed__Amount__c = newMonthlyAmount;
                }else{
                    RevenueSchedule.AcctSeed__Amount__c = temp;
                }
                
            }else{
                //RevenueSchedule.AcctSeed__Amount__c = transactionAmount;//monthlyAmount;
                RevenueSchedule.AcctSeed__Amount__c = newMonthlyAmount;
            }
            system.debug('--RevenueSchedule.AcctSeed__Amount__c----'+RevenueSchedule.AcctSeed__Amount__c);
            RevenueSchedule.AcctSeed__Amount__c = RevenueSchedule.AcctSeed__Amount__c.setScale(2, RoundingMode.FLOOR);
            tempTotal -= RevenueSchedule.AcctSeed__Amount__c;
            system.debug('--RevenueSchedule.AcctSeed__Amount__c----'+RevenueSchedule.AcctSeed__Amount__c);
            RevenueSchedule.AcctSeed__Quantity__c = 1;
            
            RevenueSchedule.AcctSeed__Credit_GL_Account__c = GLCredit;
            RevenueSchedule.AcctSeed__Debit_GL_Account__c = GLDebit;
            RevenueSchedule.Name = t.Firm_Id__r.Name.subString(0,(t.Firm_Id__r.Name.length() > 70 ? 70 : t.Firm_Id__r.Name.length() )) + '-' + schDate.year() + '/' + schDate.month();
            
            string acKey1 = 'key'+schDate.month()+'year'+schDate.year();
            if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey1)){
                RevenueSchedule.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey1).Id;
            }
            RevenueSchedule.AcctSeed__Account2__c = t.Firm_Id__c;
            RevenueSchedule.AS_Transaction__c = t.Id;
            listOfAllSchedules.add(RevenueSchedule);
            schDate = schDate.addMonths(1);
        }
        if(schDate == endDate){
            
            AcctSeed__Scheduled_Revenue_Expense__c RevenueSchedule = new AcctSeed__Scheduled_Revenue_Expense__c();
            //RevenueSchedule.AcctSeed__Amount__c = transactionAmount*(t.Policy_Id__r.Expiration_Date__c.day())/date.daysInMonth(policyEndYear , policyEndMonth);
            RevenueSchedule.AcctSeed__Amount__c = (newAmountperDay*(t.Policy_Id__r.Expiration_Date__c.day()));
            
            
            tempTotal -= RevenueSchedule.AcctSeed__Amount__c;
            RevenueSchedule.AcctSeed__Amount__c += tempTotal;
            RevenueSchedule.AcctSeed__Amount__c = RevenueSchedule.AcctSeed__Amount__c.setScale(2, RoundingMode.FLOOR);
            
            RevenueSchedule.AcctSeed__Quantity__c = 1;
            
            RevenueSchedule.AcctSeed__Credit_GL_Account__c = GLCredit;
            RevenueSchedule.AcctSeed__Debit_GL_Account__c = GLDebit;
            RevenueSchedule.Name = t.Firm_Id__r.Name.subString(0,(t.Firm_Id__r.Name.length() > 70 ? 70 : t.Firm_Id__r.Name.length() )) + '-' + schDate.year() + '/' + schDate.month();
            
            string acKey1 = 'key'+schDate.month()+'year'+schDate.year();
            if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey1)){
                RevenueSchedule.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey1).Id;
            }
            RevenueSchedule.AcctSeed__Account2__c = t.Firm_Id__c;
            RevenueSchedule.AS_Transaction__c = t.Id;
            listOfAllSchedules.add(RevenueSchedule);
        }
        system.debug('---listOfAllSchedules---'+listOfAllSchedules);
        
        
        return listOfAllSchedules;
    }
    
    //--------method to create first schedule for full amount
    public static AcctSeed__Scheduled_Revenue_Expense__c scheduleForFullAmount(AS_Transaction__c t, map<string,AcctSeed__Accounting_Period__c> mapAccountingPeriod, string GLCredit, string GLDebit,Decimal customAmount){
        
        Date transactionDate = t.Policy_Id__r.GL_Processing_Date__c != null ? t.Policy_Id__r.GL_Processing_Date__c :  (t.Policy_Id__r.Effective_Date__c >= System.today() ? t.Policy_Id__r.Effective_Date__c : System.today());
            if(t.Policy_Endorsement_Id__c != null){
                transactionDate = t.Policy_Endorsement_Id__r.GL_Processing_Date__c != null ? t.Policy_Endorsement_Id__r.GL_Processing_Date__c :  (t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c >= System.today() ? t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c : System.today());
                    }
        Decimal amount = customAmount!=null ? customAmount :  t.Amount__c;
        
        AcctSeed__Scheduled_Revenue_Expense__c RevenueSchedule = new AcctSeed__Scheduled_Revenue_Expense__c();
        string acKey1 = 'key'+transactionDate.month()+'year'+transactionDate.year();
        if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey1)){
            RevenueSchedule.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey1).Id;
        }
        RevenueSchedule.AcctSeed__Account2__c = t.Firm_Id__c;
        
        if(amount < 0){
            RevenueSchedule.AcctSeed__Amount__c = -(amount);
        }else{
            RevenueSchedule.AcctSeed__Amount__c = amount;
        }
        
        RevenueSchedule.AcctSeed__Quantity__c = 1;
        
        
        RevenueSchedule.AcctSeed__Credit_GL_Account__c = GLCredit;
        RevenueSchedule.AcctSeed__Debit_GL_Account__c = GLDebit;
        RevenueSchedule.Policy__c = t.Policy_Id__c;
        RevenueSchedule.Name = t.Firm_Id__r.Name.subString(0,(t.Firm_Id__r.Name.length() > 70 ? 70 : t.Firm_Id__r.Name.length() )) + '-' + date.valueof(t.createdDate).year() + '/' + date.valueOf(t.createdDate).month();
        RevenueSchedule.Date__c = transactionDate;
        RevenueSchedule.AS_Transaction__c  = t.Id;
        return RevenueSchedule;
    }
    
    public static AcctSeed__Scheduled_Revenue_Expense__c scheduleForFullAmount(AS_Transaction__c t, map<string,AcctSeed__Accounting_Period__c> mapAccountingPeriod, string GLCredit, string GLDebit){
        return scheduleForFullAmount(t, mapAccountingPeriod, GLCredit, GLDebit,null);
    }
    
    public static AcctSeed__Account_Payable__c createAccountsPayable(AS_Transaction__c t, map<string,AcctSeed__Accounting_Period__c>mapAccountingPeriod){
        
        AcctSeed__Account_Payable__c ap = new AcctSeed__Account_Payable__c();
        string acKey1 = 'key'+date.valueOf(t.createdDate).month()+'year'+date.valueof(t.createdDate).year();
        if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey1)){
            ap.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey1).Id;
        }
        ap.AS_Transaction__c = t.Id;
        ap.AcctSeed__Payee_Reference__c = t.Transaction_Type__c + ' - '+t.Name;
        if(t.Claim_Id__c != null){
            ap.Claim__c = t.Claim_Id__c;
        }
        if(t.Policy_Claim_Detail__c != null){
            ap.Policy_Claim_Detail__c = t.Policy_Claim_Detail__c;
        }
        if(t.Policy_Id__c != null){
            ap.Policy__c = t.Policy_Id__c;
        }
        if(t.Firm_Id__c != null){
            ap.AcctSeed__Vendor__c = t.Firm_Id__c;
        }
        return ap;
    }
    
    
    public static AcctSeed__Account_Payable__c createIBFAccountsPayable( map<string,AcctSeed__Accounting_Period__c>mapAccountingPeriod,Date effectiveDate, Id vendorId ){
        
        AcctSeed__Account_Payable__c ap = new AcctSeed__Account_Payable__c();
        string acKey1 = 'key'+date.valueOf(effectiveDate).month()+'year'+date.valueof(effectiveDate).year();
        if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey1)){
            ap.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey1).Id;
        }
        Datetime dt = effectiveDate;
        Long currentTimeLong = System.now().getTime(); 
        ap.AcctSeed__Payee_Reference__c = dt.format('MMMM') + ' IBF Payable - ' + currentTimeLong;
        System.debug('=======eeeeee'+effectiveDate);
        System.debug(dt);
        System.debug(dt.format('MMMM'));
        ap.AcctSeed__Vendor__c = vendorId;
        ap.IBF_Contribution_Month__c = effectiveDate.year() + '-' + effectiveDate.month();
        return ap;
    }
    
    
    public static AcctSeed__Account_Payable_Line__c createAPLineItems(Decimal amount, AS_Transaction__c t, string GLAccount){
        
        AcctSeed__Account_Payable_Line__c apLine = new AcctSeed__Account_Payable_Line__c();
        if(amount == null || amount == 0){
            amount = t.Amount__c;
        }else{
            
        }
        if(amount < 0){
            apLine.AcctSeed__Amount__c = -(amount);
        }else{
            apLine.AcctSeed__Amount__c = amount;
        }
        
        apLine.AcctSeed__Date__c = t.Policy_Id__r.Effective_Date__c;
        apLine.AcctSeed__Expense_GL_Account__c = GLAccount;
        apLine.IBF_Contribution_Policy__c = t.Policy_Id__c;
        apLine.Transaction_Id__c = t.Id;
        return apLine;
    }
    
    
    //@future
    public static void handleTransactionInsert(string transactionJson){
        //AcctSeed__Ledger__c ledger = [SELECT Id,Name,AcctSeed__Type__c FROM AcctSeed__Ledger__c where Name = 'Actual'];
        SavePoint sp = Database.setSavepoint();
        try{  
            system.debug('--transactionJson--'+transactionJson);
            set<string> transactionIdSet = new set<string>();
            transactionIdSet = (set<string>)JSON.deserialize(transactionJson,  set<string>.class);
            system.debug('--transactionIdSet--'+transactionIdSet);
            //------set of types for which we have to create a billing and line items and scheduled revenue expenses
            set<string> setOfTypesForPositiveBilling = new set<string>();
            setOfTypesForPositiveBilling.add('Issue Policy');
            setOfTypesForPositiveBilling.add('Add Lawyer');
            setOfTypesForPositiveBilling.add('Reinstate Policy');
            setOfTypesForPositiveBilling.add('Change Lawyer');
            setOfTypesForPositiveBilling.add('Change Coverage');
            setOfTypesForPositiveBilling.add('ERE');
            setOfTypesForPositiveBilling.add('Delete Lawyer');
            //setOfTypesForPositiveBilling.add('Change Lawyer');
            setOfTypesForPositiveBilling.add('Cancel Policy');
            setOfTypesForPositiveBilling.add('Adjust Premium');
            
            
            
            // create map of accounting periods
            map<string,AcctSeed__Accounting_Period__c> mapAccountingPeriod = new map<string,AcctSeed__Accounting_Period__c>();
            
            list<AcctSeed__Accounting_Period__c> lstAccPeriod = new list<AcctSeed__Accounting_Period__c>([SELECT id,Name,
                                                                                                          AcctSeed__Start_Date__c,AcctSeed__End_Date__c,
                                                                                                          AcctSeed__Status__c
                                                                                                          FROM 
                                                                                                          AcctSeed__Accounting_Period__c
                                                                                                          WHERE 
                                                                                                          AcctSeed__Status__c = 'Open']);
            
            for(AcctSeed__Accounting_Period__c acPeriod : lstAccPeriod)
            {
                string key = 'key'+acPeriod.AcctSeed__Start_Date__c.month()+'year'+acPeriod.AcctSeed__Start_Date__c.year();
                mapAccountingPeriod.put(key, acPeriod);
            }
            
            list<AS_Transaction__c> transactionList = new list<AS_Transaction__c>();
            //transactionList = (list<AS_Transaction__c>)JSON.deserialize(transactionJson , list<AS_Transaction__c>.class);
            transactionList = [SELECT id,name,Transaction_Type__c,Firm_Id__c,Amount__c,Policy_Id__c,createdDate,Transaction_Sub_Type__c,
                               Policy_Endorsement_Id__c,Claim_Id__c,Policy_Id__r.Effective_Date__c, Policy_Id__r.Expiration_Date__c,
                               Policy_Claim_Detail__c,Firm_Id__r.BillingCountry, Firm_Id__r.billingstreet,Firm_Id__r.billingstate,Policy_Id__r.IBF_Contribtuion__c,
                               Firm_Id__r.billingCity,Firm_Id__r.billingPostalCode,Firm_Id__r.Name,Credit_Amount__c,Dividend_Credit__c ,Policy_Id__r.PaymentReceived__c,
                               Claim_Id__r.GL_5000__c,Claim_Id__r.GL_5030__c,Claim_Id__r.Per_Claim_Deductible__c,Policy_Id__r.Treaty_Version__c,Policy_Id__r.Treaty_Version__r.Reinsurance_Limit__c,
                               Policy_Id__r.Treaty_Version__r.Ceded_4x1_Rate__c,Policy_Id__r.Treaty_Version__r.Ceded_Primary_Rate__c,Policy_Endorsement_Id__r.Endorsement_Effective_Date__c,Policy_Id__r.GL_Processing_Date__c,Policy_Endorsement_Id__r.GL_Processing_Date__c,Policy_Claim_Detail__r.Date__c,GL_Account_Name__c,
                               Policy_Endorsement_Id__r.Lawyer__r.Name,Policy_Endorsement_Id__r.Lawyer_Name__c,Policy_Id__r.Firm_Contact__c,Policy_Id__r.Account__r.AcctSeed__Billing_Contact__c,Policy_Endorsement_Id__r.Policy__r.Name,Policy_Id__r.Name,Policy_Id__r.Accounting_Processed__c,Policy_Endorsement_Id__r.Accounting_Processed__c,
                               Policy_Id__r.IBF_Contribution_Amount__c
                               FROM AS_Transaction__c 
                               WHERE Id IN: transactionIdSet AND amount__c != 0 AND Amount__c != null];
            OrgWideEmailAddress owea = [select Id from OrgWideEmailAddress where Address = 'accounting@isbamutual.com'];
            getAllEmailTemplates();
            system.debug('=---transactionList--'+transactionList);
            integer noOfTransactions = 0;
            //-----for creating map key
            map<integer, AcctSeed__Billing__c> BillingMapToInsert = new map<integer, AcctSeed__Billing__c>();
            Set<Integer> noPaymentRecievedTransaction = new Set<Integer>();
            map<integer, List<AcctSeed__Billing_Line__c>> lineItemMapToInsert = new map<integer, List<AcctSeed__Billing_Line__c>>();
            
            //-----account payable map
            
            
            map<integer, AcctSeed__Account_Payable__c> accountPayableMapToInsert = new map<integer, AcctSeed__Account_Payable__c>();
            map<integer, AcctSeed__Account_Payable_Line__c> accountPayableLinesMapToInsert = new map<integer, AcctSeed__Account_Payable_Line__c>();
            
            
            
            map<integer, list<AcctSeed__Scheduled_Revenue_Expense__c>> billSchedulesMap = new map<integer, list<AcctSeed__Scheduled_Revenue_Expense__c>>(); 
            list<AcctSeed__Scheduled_Revenue_Expense__c> schedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>(); 
            //string acKey = 'key'+date.today().month()+'year'+date.today().year();
            //-----used to fill accounting period on billing
            Map<string,Transaction_Credit_And_Debits__c> transactionCustomSettingMap = Transaction_Credit_And_Debits__c.getAll();
            system.debug('transactionCustomSettingMap ::: :: ' + transactionCustomSettingMap);
            set<string> setofAllGlNames = new set<string>();
            Set<String> setOfGLVaribles = new Set<String>();
            for(Transaction_Credit_And_Debits__c t : transactionCustomSettingMap.values()){
                setofAllGlNames.add(t.Credit_GL__c);
                setofAllGlNames.add(t.Debit_GL__c);
                if(t.GL_Variable__c != null){
                    setOfGLVaribles.add(t.GL_Variable__c );
                }
            }
            
            List<Treaty_Version_Transaction__c> treatyVersionList = new List<Treaty_Version_Transaction__c>([select id,Treaty_Version__c,GL_Account__c,Operation_Type__c,Percentage__c,Transaction_Type__c from Treaty_Version_Transaction__c]);
            
            for(Treaty_Version_Transaction__c treaty : treatyVersionList){
                system.debug('treaty.GL_Account__c :: ++ ' + treaty.GL_Account__c);
                setofAllGlNames.add(treaty.GL_Account__c);
            }
            
            List<Account> IBFvendor = [select id from Account where Name =: Label.IBF_Contribution_Vendor];
            
            Map<String,AcctSeed__Account_Payable__c> mapIBFPayable = new Map<String,AcctSeed__Account_Payable__c>();
            
            for(AcctSeed__Account_Payable__c payable : [select id,IBF_Contribution_Month__c from AcctSeed__Account_Payable__c where AcctSeed__Status__c != 'Posted' and AcctSeed__Accounting_Period__r.AcctSeed__Status__c = 'Open' and AcctSeed__Payee_Reference__c like '%IBF Payable%' and IBF_Contribution_Month__c !=null and AcctSeed__Vendor__r.Name =: Label.IBF_Contribution_Vendor ]){
                mapIBFPayable.put(payable.IBF_Contribution_Month__c,payable);
            }
            
            setofAllGlNames.add(Label.Main_Cash_GL);
            system.debug('setofAllGlNames ++ ' + setofAllGlNames);
            map<string, AcctSeed__GL_Account__c> mapOfGlAccounts = new map<string, AcctSeed__GL_Account__c>();
            map<string, AcctSeed__Accounting_Variable__c > mapGlVariables = new map<string, AcctSeed__Accounting_Variable__c >();
            //-------journal entry and line items map
            map<integer, AcctSeed__Journal_Entry__c> JournalEntryMapToInsert = new map<integer, AcctSeed__Journal_Entry__c>();
            map<integer, list<AcctSeed__Journal_Entry_Line__c>> JournalEntryLineItemsMapToInsert = new map<integer, list<AcctSeed__Journal_Entry_Line__c>>();
            set<Id> claimIds = new set<Id>();
            
            for(AcctSeed__GL_Account__c a : [select id, name from AcctSeed__GL_Account__c where name IN:setofAllGlNames]){
                mapOfGlAccounts.put(a.name, a);
            }
            for(AcctSeed__Accounting_Variable__c  var : [select id,name from AcctSeed__Accounting_Variable__c  where Name in: setOfGLVaribles]){
                mapGlVariables.put(var.Name,var);
            }
            system.debug('mapOfGlAccounts ::: ' + mapOfGlAccounts);
            //-----map to be used for inserting gl credit and gl debit in schedule records
            
            for(AS_Transaction__c t : transactionList){
                
                if(t.Claim_Id__c != null){
                    claimIds.add(t.Claim_Id__c);
                }
            }
            
            PolicyClaimMap = new Map<Id,Policy_Claim__c>([SELECT Id,Name,JE_Entry_Name_Number__c 
                                                          FROM Policy_Claim__c WHERE Id IN: claimIds]); 
            
            Map<String,AcctSeed__Billing_Format__c> billingFormats = new Map<String,AcctSeed__Billing_Format__c>();
            for(AcctSeed__Billing_Format__c format : [Select id,Name,AcctSeed__Visualforce_PDF_Page__c ,AcctSeed__Default_Email_Template__c 
                                                      from AcctSeed__Billing_Format__c]){
                                                          billingFormats.put(format.Name,format);
                                                      }
            
            List<AcctSeed__Billing_Format__c> deductibleBillingFormat = new List<AcctSeed__Billing_Format__c>();
            Map<Id,Policy_Endorsement__c> endorsementToUpdate = new Map<Id,Policy_Endorsement__c>();
            Map<Id,Policy__c> policyToUpdate = new Map<Id,Policy__c>();
            Map<Integer,Id> policyToUpdateMap = new Map<Integer,Id>();
            for(AS_Transaction__c t : transactionList){
                Date transactionDate = t.Policy_Id__r.GL_Processing_Date__c != null ? t.Policy_Id__r.GL_Processing_Date__c :  (t.Policy_Id__r.Effective_Date__c >= System.today() ? t.Policy_Id__r.Effective_Date__c : System.today());
                    if(t.Policy_Endorsement_Id__c != null){
                        transactionDate = t.Policy_Endorsement_Id__r.GL_Processing_Date__c != null ? t.Policy_Endorsement_Id__r.GL_Processing_Date__c :  (t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c >= System.today() ? t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c : System.today());
                            if(!t.Policy_Endorsement_Id__r.Accounting_Processed__c ){
                                endorsementToUpdate.put(t.Policy_Endorsement_Id__c,new Policy_Endorsement__c(Id=t.Policy_Endorsement_Id__c,Accounting_Processed__c = true,GL_Processing_Date__c = transactionDate));
                            }
                    }else if(t.Policy_Id__c !=null && !t.Policy_Id__r.Accounting_Processed__c){
                        policyToUpdate.put(t.Policy_Id__c,new Policy__c(Id=t.Policy_Id__c,Accounting_Processed__c = true,GL_Processing_Date__c = transactionDate));
                    }
                if(t.Transaction_Type__c == 'ERE' && t.Amount__c < 0){
                    transactionDate = System.today();
                }
                string acKey = 'key'+transactionDate.month()+'year'+transactionDate.year();
                //---------checking if we have to create billing and billing line item
                noOfTransactions += 1;
                System.debug('Ttype'+t.Transaction_Type__c);
                System.debug('setOfTypesForPositiveBilling' + setOfTypesForPositiveBilling);
                System.debug('sgsjsjsjs'+setOfTypesForPositiveBilling.contains(t.Transaction_Type__c));
                
                if(t.Transaction_Type__c != null && setOfTypesForPositiveBilling != null && setOfTypesForPositiveBilling.contains(t.Transaction_Type__c) ){
                    AcctSeed__Billing__c bill = new AcctSeed__Billing__c();
                    if(!(t.Transaction_Type__c == 'Issue Policy' || t.Transaction_Type__c == 'Delete Lawyer' || t.Transaction_Type__c == 'Add Lawyer' || t.Transaction_Type__c == 'ERE' || t.Transaction_Type__c == 'Cancel Policy')){
                        bill = createBilling(t);
                       // bill.AcctSeed__Ledger__c = ledger.Id;
                        
                        if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey)){
                            bill.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey).id;
                        }
                        system.debug('---t.Transaction_Type__c--'+t.Transaction_Type__c);
                        billingMapToInsert.put(noOfTransactions , bill);
                        
                        
                        system.debug('---t.--'+t);
                    }
                    //-------creating revenue schedules
                    if(t.Transaction_Type__c == 'Issue Policy' && t.Transaction_Sub_Type__c == 'Premium'){
                        
                        if(t.Policy_Id__r.PaymentReceived__c == 'No Payment Received' && System.label.Enable_Send_Billing_Email_on_Bind == 'Y'){
                            noPaymentRecievedTransaction.add(noOfTransactions);
                        }
                        bill = createBilling(t,billingFormats);
                       // bill.AcctSeed__Ledger__c = ledger.Id;
                        
                        if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey)){
                            bill.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey).id;
                        }
                        system.debug('---t.Transaction_Type__c--'+t.Transaction_Type__c);
                        billingMapToInsert.put(noOfTransactions , bill);
                        policyToUpdateMap.put(noOfTransactions,t.Policy_Id__c);
                        
                        
                        system.debug('---t.--'+t);
                        
                        system.debug('transactionCustomSettingMap ::: :: ' + transactionCustomSettingMap);
                        system.debug('transactionCustomSettingMap ::: :: ' + transactionCustomSettingMap.values());
                        
                        if(transactionCustomSettingMap != null && transactionCustomSettingMap.containsKey('Billing Line')){
                            AcctSeed__Billing_Line__c billLineItem = new AcctSeed__Billing_Line__c();
                            AcctSeed__Billing_Line__c billLineItem1 = new AcctSeed__Billing_Line__c();
                            AcctSeed__Billing_Line__c billLineItem2 = new AcctSeed__Billing_Line__c();
                            List<AcctSeed__Billing_Line__c> billingLinesListToAdd = new List<AcctSeed__Billing_Line__c>();
                            billLineItem = createBillingLineItem(t.Amount__c , true, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Credit_GL__c).Id);
                            billLineItem.AcctSeed__Comment__c = 'Policy Premium #' + t.Policy_Id__r.Name;
                            system.debug('billLineItem --> ' + billLineItem);
                            system.debug('t.Credit_Amount__c :: ' + t.Credit_Amount__c);
                            billingLinesListToAdd.add(billLineItem);
                            if(t.Dividend_Credit__c != null && t.Dividend_Credit__c  != 0){
                                Decimal dividendCreditAmount = t.Dividend_Credit__c - t.Policy_Id__r.IBF_Contribution_Amount__c;
                                
                                if(dividendCreditAmount != 0){
                                    if(transactionCustomSettingMap.containsKey('Dividend Credit Billing Line')){
                                        billLineItem2 = createBillingLineItem(-dividendCreditAmount , true, mapOfGlAccounts.get(transactionCustomSettingMap.get('Dividend Credit Billing Line').Debit_GL__c).Id, 
                                                                              mapOfGlAccounts.get(transactionCustomSettingMap.get('Dividend Credit Billing Line').Credit_GL__c).Id);
                                        billLineItem2.AcctSeed__GL_Account_Variable_2__c = mapGlVariables.get(transactionCustomSettingMap.get('Dividend Credit Billing Line').GL_Variable__c ).Id;
                                    }else{
                                        billLineItem2 = createBillingLineItem(-dividendCreditAmount , true, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Debit_GL__c).Id, 
                                                                              mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Credit_GL__c).Id);
                                    }
                                    billLineItem2.AcctSeed__Comment__c = ((t.Policy_Id__r.Effective_Date__c.year()) - 1) + ' Dividend Credit';
                                    billingLinesListToAdd.add(billLineItem2);
                                }
                                System.debug(mapIBFPayable);
                                if(t.Policy_Id__r.IBF_Contribution_Amount__c > 0){
                                    if(mapIBFPayable.containsKey(t.Policy_Id__r.Effective_Date__c.year() + '-' + t.Policy_Id__r.Effective_Date__c.month())){
                                        accountPayableMapToInsert.put(noOfTransactions, mapIBFPayable.get(t.Policy_Id__r.Effective_Date__c.year() + '-' + t.Policy_Id__r.Effective_Date__c.month()));
                                    }else{
                                        accountPayableMapToInsert.put(noOfTransactions, createIBFAccountsPayable(mapAccountingPeriod,t.Policy_Id__r.Effective_Date__c,IBFvendor[0].Id));
                                    }
                                    if(transactionCustomSettingMap.containsKey('Dividend Credit Billing Line')){
                                        accountPayableLinesMapToInsert.put(noOfTransactions, createAPLineItems(t.Policy_Id__r.IBF_Contribution_Amount__c,t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Dividend Credit Billing Line').Credit_GL__c).Id));
                                    }else{
                                        accountPayableLinesMapToInsert.put(noOfTransactions, createAPLineItems(t.Policy_Id__r.IBF_Contribution_Amount__c,t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Credit_GL__c).Id));
                                    }
                                    
                                    
                                    
                                }
                            }
                            if(t.Credit_Amount__c != null && t.Credit_Amount__c != 0){
                                
                                if(transactionCustomSettingMap.containsKey('Credit Billing Line')){
                                    billLineItem1 = createBillingLineItem(-t.Credit_Amount__c , true, mapOfGlAccounts.get(transactionCustomSettingMap.get('Credit Billing Line').Debit_GL__c).Id, 
                                                                          mapOfGlAccounts.get(transactionCustomSettingMap.get('Credit Billing Line').Credit_GL__c).Id);
                                }else{
                                    billLineItem1 = createBillingLineItem(-t.Credit_Amount__c , true, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Debit_GL__c).Id, 
                                                                          mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Credit_GL__c).Id);
                                }
                                billLineItem1.AcctSeed__Comment__c = 'CLE Credit';
                                billingLinesListToAdd.add(billLineItem1);
                            }
                            lineItemMapToInsert.put(noOfTransactions , billingLinesListToAdd);
                            
                            
                            
                            //-------map of billing line items
                            
                            if(t.Amount__c < 0){
                                list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                                tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').debit_GL__c).Id));
                                
                                tempSchedules.addAll(createRevenueSchedules(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').credit_GL__c).Id));
                                billSchedulesMap.put(noOfTransactions , tempSchedules);
                            }else{
                                list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                                tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').credit_GL__c).Id));
                                
                                tempSchedules.addAll(createRevenueSchedules(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Debit_GL__c).Id));
                                billSchedulesMap.put(noOfTransactions , tempSchedules);
                            }
                            
                        }
                    }else if(t.Transaction_Type__c != null && (t.Transaction_Type__c == 'Issue Policy' || t.Transaction_Type__c == 'Delete Lawyer' || t.Transaction_Type__c == 'Add Lawyer'  || t.Transaction_Type__c == 'ERE' || t.Transaction_Type__c == 'Cancel Policy') && t.Transaction_Sub_Type__c == '5x5' ){
                        list<AcctSeed__Journal_Entry_Line__c> journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>();
                        Decimal creditAmount = 0, debitAmount = 0;
                        Decimal amount;
                        for(Treaty_Version_Transaction__c treaty : treatyVersionList){
                            if(treaty.Treaty_Version__c == t.Policy_Id__r.Treaty_Version__c && treaty.Transaction_Type__c == t.Transaction_Sub_Type__c && mapOfGlAccounts.containsKey(treaty.GL_Account__c)){
                                amount = ((t.Amount__c*treaty.Percentage__c)/100).setscale(2,RoundingMode.FLOOR);
                                if(treaty.Operation_Type__c == 'Credit'){
                                    creditAmount += amount;
                                }else{
                                    debitAmount += amount;
                                }
                                if(Math.abs(debitAmount - creditAmount) >=0 && Math.abs(debitAmount - creditAmount) < 0.1){
                                    if(treaty.Operation_Type__c == 'Credit'){
                                        amount += (debitAmount - creditAmount);
                                    }else{
                                        amount -= (debitAmount - creditAmount);
                                    }
                                }
                                journalLineItemList.add(journalLineItem(t, treaty.Operation_Type__c , mapOfGlAccounts.get(treaty.GL_Account__c).Id,amount));
                            }
                        }
                        
                        if(journalLineItemList.size()>0){
                            JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t,mapAccountingPeriod, null,null));
                            JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                        }
                        if(t.Transaction_Type__c != 'ERE'){
                            if(t.Amount__c < 0){
                                list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                                tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Issue Policy 5x5 Amortize').credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Issue Policy 5x5 Amortize').debit_GL__c).Id));
                                
                                tempSchedules.addAll(createRevenueSchedules(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Issue Policy 5x5 Amortize').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Issue Policy 5x5 Amortize').credit_GL__c).Id));
                                schedules.addAll(tempSchedules);
                            }else{
                                list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                                tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Issue Policy 5x5 Amortize').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Issue Policy 5x5 Amortize').credit_GL__c).Id));
                                
                                tempSchedules.addAll(createRevenueSchedules(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Issue Policy 5x5 Amortize').Credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Issue Policy 5x5 Amortize').Debit_GL__c).Id));
                                schedules.addAll(tempSchedules);
                            }
                        }
                    }else if(t.Transaction_Type__c != null && (t.Transaction_Type__c == 'Issue Policy' || t.Transaction_Type__c == 'Delete Lawyer' || t.Transaction_Type__c == 'Add Lawyer'  || t.Transaction_Type__c == 'ERE' || t.Transaction_Type__c == 'Cancel Policy') && t.Transaction_Sub_Type__c == '10x10'){
                        
                        list<AcctSeed__Journal_Entry_Line__c> journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>();
                        
                        for(Treaty_Version_Transaction__c treaty : treatyVersionList){
                            if(treaty.Treaty_Version__c == t.Policy_Id__r.Treaty_Version__c && treaty.Transaction_Type__c == t.Transaction_Sub_Type__c && mapOfGlAccounts.containsKey(treaty.GL_Account__c)){
                                journalLineItemList.add(journalLineItem(t, treaty.Operation_Type__c , mapOfGlAccounts.get(treaty.GL_Account__c).Id,(t.Amount__c*treaty.Percentage__c)/100));
                            }
                        }
                        
                        if(journalLineItemList.size()>0){
                            JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t,mapAccountingPeriod, null,null));
                            JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                        }
                        if(t.Transaction_Type__c != 'ERE'){
                            if(t.Amount__c < 0){
                                list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                                tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Issue Policy 10x10 Amortize').credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Issue Policy 10x10 Amortize').debit_GL__c).Id));
                                
                                tempSchedules.addAll(createRevenueSchedules(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Issue Policy 10x10 Amortize').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Issue Policy 10x10 Amortize').credit_GL__c).Id));
                                schedules.addAll(tempSchedules);
                            }else{
                                list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                                tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Issue Policy 10x10 Amortize').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Issue Policy 10x10 Amortize').credit_GL__c).Id));
                                
                                tempSchedules.addAll(createRevenueSchedules(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Issue Policy 10x10 Amortize').credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Issue Policy 10x10 Amortize').debit_GL__c).Id));
                                schedules.addAll(tempSchedules);
                            }
                        }
                    }else if(t.Transaction_Type__c != null && (t.Transaction_Type__c == 'Issue Policy' || t.Transaction_Type__c == 'Delete Lawyer' || t.Transaction_Type__c == 'Add Lawyer' || t.Transaction_Type__c == 'ERE' || t.Transaction_Type__c == 'Cancel Policy') && t.Transaction_Sub_Type__c == 'Primary'){
                        
                        list<AcctSeed__Journal_Entry_Line__c> journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>();
                        
                        journalLineItemList.add(journalLineItem(t, 'Debit' , mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary').debit_GL__c).Id,(t.Amount__c*t.Policy_Id__r.Treaty_Version__r.Ceded_Primary_Rate__c)/100));
                        journalLineItemList.add(journalLineItem(t, 'Credit' , mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary').credit_GL__c).Id,(t.Amount__c*t.Policy_Id__r.Treaty_Version__r.Ceded_Primary_Rate__c)/100));
                        
                        if(journalLineItemList.size()>0){
                            JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t,mapAccountingPeriod, null,null));
                            JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                        }
                        if(t.Transaction_Type__c != 'ERE'){
                            if(t.Amount__c < 0){
                                list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                                tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary Amortize').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary Amortize').credit_GL__c).Id,(t.Amount__c*t.Policy_Id__r.Treaty_Version__r.Ceded_Primary_Rate__c)/100));
                                
                                tempSchedules.addAll(createRevenueSchedules(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary Amortize').credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary Amortize').debit_GL__c).Id,(t.Amount__c*t.Policy_Id__r.Treaty_Version__r.Ceded_Primary_Rate__c)/100));
                                schedules.addAll(tempSchedules);
                            }else{
                                list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                                tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary Amortize').credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary Amortize').debit_GL__c).Id,(t.Amount__c*t.Policy_Id__r.Treaty_Version__r.Ceded_Primary_Rate__c)/100));
                                
                                tempSchedules.addAll(createRevenueSchedules(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary Amortize').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Primary Amortize').credit_GL__c).Id,(t.Amount__c*t.Policy_Id__r.Treaty_Version__r.Ceded_Primary_Rate__c)/100));
                                schedules.addAll(tempSchedules);
                            }
                        }
                    }else if(t.Transaction_Type__c != null && (t.Transaction_Type__c == 'Issue Policy' || t.Transaction_Type__c == 'Delete Lawyer' || t.Transaction_Type__c == 'Add Lawyer' || t.Transaction_Type__c == 'ERE' || t.Transaction_Type__c == 'Cancel Policy') && t.Transaction_Sub_Type__c == 'PrimaryAndExcess'){
                        
                        list<AcctSeed__Journal_Entry_Line__c> journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>();
                        
                        journalLineItemList.add(journalLineItem(t, 'Debit' , mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1').debit_GL__c).Id,(t.Amount__c*t.Policy_Id__r.Treaty_Version__r.Ceded_4x1_Rate__c)/100));
                        journalLineItemList.add(journalLineItem(t, 'Credit' , mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1').credit_GL__c).Id,(t.Amount__c*t.Policy_Id__r.Treaty_Version__r.Ceded_4x1_Rate__c)/100));
                        
                        if(journalLineItemList.size()>0){
                            JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t,mapAccountingPeriod, null,null));
                            JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                        }
                        if(t.Transaction_Type__c != 'ERE'){
                            if(t.Amount__c < 0){
                                list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                                tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1 Amortize').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1 Amortize').Credit_GL__c).Id,(t.Amount__c*t.Policy_Id__r.Treaty_Version__r.Ceded_4x1_Rate__c)/100));
                                
                                tempSchedules.addAll(createRevenueSchedules(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1 Amortize').Credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1 Amortize').debit_GL__c).Id,(t.Amount__c*t.Policy_Id__r.Treaty_Version__r.Ceded_4x1_Rate__c)/100));
                                schedules.addAll(tempSchedules);
                            }else{
                                list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                                tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1 Amortize').Credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1 Amortize').debit_GL__c).Id,(t.Amount__c*t.Policy_Id__r.Treaty_Version__r.Ceded_4x1_Rate__c)/100));
                                
                                tempSchedules.addAll(createRevenueSchedules(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1 Amortize').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded 4x1 Amortize').Credit_GL__c).Id,(t.Amount__c*t.Policy_Id__r.Treaty_Version__r.Ceded_4x1_Rate__c)/100));
                                schedules.addAll(tempSchedules);
                            }
                        }
                    }
                    else if(t.Transaction_Type__c == 'Add Lawyer' && t.Transaction_Sub_Type__c == 'Add Lawyer'){
                        bill = createBilling(t,billingFormats);
                       // bill.AcctSeed__Ledger__c = ledger.Id;
                        
                        if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey)){
                            bill.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey).id;
                        }
                        system.debug('---t.Transaction_Type__c--'+t.Transaction_Type__c);
                        billingMapToInsert.put(noOfTransactions , bill);
                        
                        
                        system.debug('---t.--'+t);
                        if(transactionCustomSettingMap != null && transactionCustomSettingMap.containsKey('Billing Line')){
                            AcctSeed__Billing_Line__c billLineItem = new AcctSeed__Billing_Line__c();
                            billLineItem = createBillingLineItem(t.Amount__c , true, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Debit_GL__c).Id, 
                                                                 mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Credit_GL__c).Id);
                            billLineItem.AcctSeed__Comment__c = 'Policy #' + t.Policy_Id__r.Name + ' - Add Lawyer - ' + t.Policy_Endorsement_Id__r.Lawyer__r.Name;
                            lineItemMapToInsert.put(noOfTransactions , new AcctSeed__Billing_Line__c[]{billLineItem});
                            
                            list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                            tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').credit_GL__c).Id));
                            
                            tempSchedules.addAll(createRevenueSchedules(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Debit_GL__c).Id));
                            billSchedulesMap.put(noOfTransactions , tempSchedules);
                        }
                        
                    }
                    else if(t.Transaction_Type__c == 'Adjust Premium'){
                        if(transactionCustomSettingMap != null && transactionCustomSettingMap.containsKey('Billing Line')){
                            AcctSeed__Billing_Line__c billLineItem = new AcctSeed__Billing_Line__c();
                            if(t.Amount__c < 0){
                                billLineItem = createBillingLineItem(t.Amount__c , false, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Debit_GL__c).Id, 
                                                                     mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Credit_GL__c).Id);
                            
                                lineItemMapToInsert.put(noOfTransactions , new AcctSeed__Billing_Line__c[]{billLineItem});
                                
                                list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                                tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').debit_GL__c).Id));
                                
                                tempSchedules.addAll(createRevenueSchedulesForComingMonths(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Credit_GL__c).Id));
                                billSchedulesMap.put(noOfTransactions , tempSchedules);
                            }
                            
                            else{
                                billLineItem = createBillingLineItem(t.Amount__c , true, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Debit_GL__c).Id, 
                                                                     mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Credit_GL__c).Id);
                              
                                lineItemMapToInsert.put(noOfTransactions , new AcctSeed__Billing_Line__c[]{billLineItem});
                                
                                list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                                tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').credit_GL__c).Id));
                                
                                tempSchedules.addAll(createRevenueSchedulesForComingMonths(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Debit_GL__c).Id));
                                billSchedulesMap.put(noOfTransactions , tempSchedules); 
                            }               
                            
                        }
                        
                    }
                    else if(t.Transaction_Type__c == 'Change Lawyer'){
                        if(transactionCustomSettingMap != null && transactionCustomSettingMap.containsKey('Billing Line')){
                            AcctSeed__Billing_Line__c billLineItem = new AcctSeed__Billing_Line__c();
                            if(t.Amount__c < 0){
                                billLineItem = createBillingLineItem(t.Amount__c , false, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Debit_GL__c).Id, 
                                                                     mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Credit_GL__c).Id);
                               
                                lineItemMapToInsert.put(noOfTransactions , new AcctSeed__Billing_Line__c[]{billLineItem});
                                
                                list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                                tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').debit_GL__c).Id));
                                
                                tempSchedules.addAll(createRevenueSchedulesForComingMonths(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Credit_GL__c).Id));
                                billSchedulesMap.put(noOfTransactions , tempSchedules);
                            }
                            
                            else{
                                billLineItem = createBillingLineItem(t.Amount__c , true, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Debit_GL__c).Id, 
                                                                     mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Credit_GL__c).Id);
                                
                                lineItemMapToInsert.put(noOfTransactions , new AcctSeed__Billing_Line__c[]{billLineItem});
                                
                                list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                                tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').credit_GL__c).Id));
                                
                                tempSchedules.addAll(createRevenueSchedulesForComingMonths(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Debit_GL__c).Id));
                                billSchedulesMap.put(noOfTransactions , tempSchedules); 
                            }               
                            
                        }
                        
                    }
                    else if(t.Transaction_Type__c == 'Delete Lawyer' && t.Transaction_Sub_Type__c == 'Delete Lawyer'){
                        bill = createBilling(t,billingFormats);
                        //bill.AcctSeed__Ledger__c = ledger.Id;
                        
                        if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey)){
                            bill.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey).id;
                        }
                        system.debug('---t.Transaction_Type__c--'+t.Transaction_Type__c);
                        billingMapToInsert.put(noOfTransactions , bill);
                        
                        
                        system.debug('---t.--'+t);
                        if(transactionCustomSettingMap != null && transactionCustomSettingMap.containsKey('Delete Lawyer')){
                            AcctSeed__Billing_Line__c billLineItem = new AcctSeed__Billing_Line__c();
                            billLineItem = createBillingLineItem(t.Amount__c , false, mapOfGlAccounts.get(transactionCustomSettingMap.get('Delete Lawyer').Debit_GL__c).Id, 
                                                                 mapOfGlAccounts.get(transactionCustomSettingMap.get('Delete Lawyer').Credit_GL__c).Id);
                            billLineItem.AcctSeed__Comment__c = 'Policy #' + t.Policy_Id__r.Name + ' - Delete Lawyer - ' + t.Policy_Endorsement_Id__r.Lawyer_Name__c;  
                            lineItemMapToInsert.put(noOfTransactions , new AcctSeed__Billing_Line__c[]{billLineItem});
                            
                            list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                            tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').debit_GL__c).Id));
                            
                            tempSchedules.addAll(createRevenueSchedules(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Credit_GL__c).Id));
                            billSchedulesMap.put(noOfTransactions , tempSchedules);
                        }
                    }
                    
                    /////-------------------------------code edited-----------------------------------------------
                    else if (t.Transaction_Type__c == 'ERE' && t.Transaction_Sub_Type__c == 'ERE') {
                        bill = createBilling(t,billingFormats);
                        //bill.AcctSeed__Ledger__c = ledger.id;
                        
                        if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey)){
                            bill.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey).id;
                        }
                        system.debug('---t.Transaction_Type__c--'+t.Transaction_Type__c);
                        billingMapToInsert.put(noOfTransactions , bill);
                        
                        if (transactionCustomSettingMap != null && transactionCustomSettingMap.containsKey('ERE')){
                            AcctSeed__Billing_Line__c billLineItem = new AcctSeed__Billing_Line__c();
                            billLineItem = createBillingLineItem(t.Amount__c, true, mapOfGlAccounts.get(transactionCustomSettingMap.get('ERE').Debit_GL__c).Id, 
                                                                 mapOfGlAccounts.get(transactionCustomSettingMap.get('ERE').Credit_GL__c).Id);
                            billLineItem.AcctSeed__Comment__c = 'Extended Reporting Period Premium: Policy #' + t.Policy_Endorsement_Id__r.Policy__r.Name;
                            lineItemMapToInsert.put(noOfTransactions, new AcctSeed__Billing_Line__c[]{billLineItem});
                        }
                    } else if (t.Transaction_Type__c == 'Cancel Policy') {
                        bill = createBilling(t);
                        
                        if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey)){
                            bill.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey).id;
                        }
                        system.debug('---t.Transaction_Type__c--'+t.Transaction_Type__c);
                        billingMapToInsert.put(noOfTransactions , bill);
                        
                        
                        system.debug('---t.--'+t);
                        if(transactionCustomSettingMap != null && transactionCustomSettingMap.containsKey('Delete Lawyer')){
                            AcctSeed__Billing_Line__c billLineItem = new AcctSeed__Billing_Line__c();
                            billLineItem = createBillingLineItem(t.Amount__c , false, mapOfGlAccounts.get(transactionCustomSettingMap.get('Delete Lawyer').Debit_GL__c).Id, 
                                                                 mapOfGlAccounts.get(transactionCustomSettingMap.get('Delete Lawyer').Credit_GL__c).Id);
                            billLineItem.AcctSeed__Comment__c = 'Policy Cancel Credit #' + t.Policy_Id__r.Name;
                            lineItemMapToInsert.put(noOfTransactions , new AcctSeed__Billing_Line__c[]{billLineItem});
                            
                            list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                            tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').debit_GL__c).Id));
                            
                            tempSchedules.addAll(createRevenueSchedules(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Credit_GL__c).Id));
                            billSchedulesMap.put(noOfTransactions , tempSchedules);
                        }
                    } else if (t.Transaction_Type__c == 'Reinstate Policy') {
                        if (transactionCustomSettingMap != null && transactionCustomSettingMap.containsKey('Billing Line')){
                            
                            AcctSeed__Billing_Line__c billLineItem = new AcctSeed__Billing_Line__c();
                            billLineItem = createBillingLineItem(t.Amount__c , true, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Debit_GL__c).Id, 
                                                                 mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Credit_GL__c).Id);
                            billLineItem.AcctSeed__Comment__c = 'Policy Premium #' + t.Policy_Id__r.Name;
                            lineItemMapToInsert.put(noOfTransactions , new AcctSeed__Billing_Line__c[]{billLineItem});
                            
                            list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                            tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').credit_GL__c).Id));
                            
                            tempSchedules.addAll(createRevenueSchedules(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Debit_GL__c).Id));
                            billSchedulesMap.put(noOfTransactions , tempSchedules);
                            
                            
                            /*AcctSeed__Billing_Line__c billLineItem = new AcctSeed__Billing_Line__c();

if(t.Amount__c < 0){
billLineItem = createBillingLineItem(t.Amount__c, false, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Debit_GL__c).Id, 
mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Credit_GL__c).Id);

lineItemMapToInsert.put(noOfTransactions, new AcctSeed__Billing_Line__c[]{billLineItem});
list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').credit_GL__c).Id));

tempSchedules.addAll(createRevenueSchedulesForComingMonths(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').debit_GL__c).Id));
billSchedulesMap.put(noOfTransactions , tempSchedules);
}else{
billLineItem = createBillingLineItem(t.Amount__c, true, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Debit_GL__c).Id, 
mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Credit_GL__c).Id);

lineItemMapToInsert.put(noOfTransactions, new AcctSeed__Billing_Line__c[]{billLineItem});
list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Debit_GL__c).Id));

tempSchedules.addAll(createRevenueSchedulesForComingMonths(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').credit_GL__c).Id));
billSchedulesMap.put(noOfTransactions , tempSchedules);
}*/
                            
                        }
                        
                    } else if (t.Transaction_Type__c == 'Change Coverage') {
                        system.debug(string.valueOf(t.Amount__c));
                        if (t.Amount__c < 0 ) {
                            system.debug('***');
                            if (transactionCustomSettingMap != null && transactionCustomSettingMap.containsKey('Billing Line')){
                                AcctSeed__Billing_Line__c billLineItem = new AcctSeed__Billing_Line__c();
                                billLineItem = createBillingLineItem(t.Amount__c, false, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Debit_GL__c).Id, 
                                                                     mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Credit_GL__c).Id);
                                
                                lineItemMapToInsert.put(noOfTransactions, new AcctSeed__Billing_Line__c[]{billLineItem});
                                
                                list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                                tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Debit_GL__c).Id));
                                
                                tempSchedules.addAll(createRevenueSchedulesForComingMonths(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Credit_GL__c).Id));
                                billSchedulesMap.put(noOfTransactions , tempSchedules);
                            } 
                            
                        }else{
                            
                            if (transactionCustomSettingMap != null && transactionCustomSettingMap.containsKey('Billing Line')){
                                AcctSeed__Billing_Line__c billLineItem = new AcctSeed__Billing_Line__c();
                                billLineItem = createBillingLineItem(t.Amount__c, true, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Debit_GL__c).Id, 
                                                                     mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Line').Credit_GL__c).Id);
                                
                                lineItemMapToInsert.put(noOfTransactions, new AcctSeed__Billing_Line__c[]{billLineItem});
                                
                                list<AcctSeed__Scheduled_Revenue_Expense__c> tempSchedules = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
                                tempSchedules.add(scheduleForFullAmount(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').credit_GL__c).Id));
                                
                                tempSchedules.addAll(createRevenueSchedulesForComingMonths(t , mapAccountingPeriod, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Billing Schedule').Debit_GL__c).Id));
                                billSchedulesMap.put(noOfTransactions , tempSchedules);
                            }
                        }
                    }
                    //-----------------------till here----------------------------
                    
                    
                }
                
                //-------part 2 for claims object where we create corresponding journal Entries
                if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Open Reserve'){
                    
                    
                    
                    list<AcctSeed__Journal_Entry_Line__c> journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>();
                    if(t.Transaction_Sub_Type__c == 'Open Reserve LAE'){
                        JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t, mapAccountingPeriod,transactionCustomSettingMap.get('Open Reserve LAE').Debit_GL__c,transactionCustomSettingMap.get('Open Reserve LAE').Credit_GL__c));
                        journalLineItemList = journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Open Reserve LAE').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Open Reserve LAE').Credit_GL__c).Id);
                        JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                    }
                    else if(t.Transaction_Sub_Type__c == 'Open Reserve Loss'){
                        JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t, mapAccountingPeriod,transactionCustomSettingMap.get('Open Reserve Loss').Debit_GL__c,transactionCustomSettingMap.get('Open Reserve Loss').Credit_GL__c));
                        journalLineItemList = journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Open Reserve Loss').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Open Reserve Loss').Credit_GL__c).Id);
                        JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                    }
                    
                }
                else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Close Reserve'){
                    list<AcctSeed__Journal_Entry_Line__c> journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>();
                    if(t.Transaction_Sub_Type__c == 'Close Reserve LAE'){
                        JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t, mapAccountingPeriod,transactionCustomSettingMap.get('Close Reserve LAE').Credit_GL__c,transactionCustomSettingMap.get('Close Reserve LAE').Debit_GL__c));
                        journalLineItemList = journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Close Reserve LAE').Credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Close Reserve LAE').Debit_GL__c).Id);
                        JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                    }
                    else if(t.Transaction_Sub_Type__c == 'Close Reserve Loss'){
                        JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t, mapAccountingPeriod,transactionCustomSettingMap.get('Close Reserve Loss').Credit_GL__c,transactionCustomSettingMap.get('Close Reserve Loss').Debit_GL__c));
                        journalLineItemList = journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Close Reserve Loss').Credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Close Reserve Loss').Debit_GL__c).Id);
                        JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                    }
                    
                }
                else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Change in Ceded LAE Reserve'){
                    JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t, mapAccountingPeriod,transactionCustomSettingMap.get('Ceded Reserve LAE').Debit_GL__c,transactionCustomSettingMap.get('Ceded Reserve LAE').Credit_GL__c));
                    
                    list<AcctSeed__Journal_Entry_Line__c> journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>();
                    journalLineItemList = journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Reserve LAE').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Reserve LAE').Credit_GL__c).Id);
                    JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                }
                else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Change in Ceded Loss Reserve'){
                    JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t, mapAccountingPeriod,transactionCustomSettingMap.get('Ceded Reserve Loss').Debit_GL__c,transactionCustomSettingMap.get('Ceded Reserve Loss').Credit_GL__c));
                    
                    list<AcctSeed__Journal_Entry_Line__c> journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>();
                    journalLineItemList = journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Reserve Loss').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Reserve Loss').Credit_GL__c).Id);
                    JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                }
                else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Claim Coverage - ARDC'){
                    /*JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t, mapAccountingPeriod,transactionCustomSettingMap.get('Close Reserve Loss').Debit_GL__c,transactionCustomSettingMap.get('Close Reserve Loss').Credit_GL__c));

list<AcctSeed__Journal_Entry_Line__c> journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>();
journalLineItemList = journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Close Reserve Loss').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Close Reserve Loss').Credit_GL__c).Id);
JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
*/
                    if(t.Amount__c < 0){
                        JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t, mapAccountingPeriod,t.GL_Account_Name__c,Label.Main_Cash_GL));
                        list<AcctSeed__Journal_Entry_Line__c> journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>();
                        
                        journalLineItemList.addAll(journalLineItems(t, t.GL_Account_Name__c, mapOfGlAccounts.get(Label.Main_Cash_GL).Id,0));
                        
                        JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                    }
                }
                else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'LAE Payment'){
                    //accountPayableMapToInsert.put(noOfTransactions, createAccountsPayable(t, mapAccountingPeriod));
                    
                    list<AcctSeed__Journal_Entry_Line__c> journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>();
                    if(t.Transaction_Sub_Type__c == 'LAE Payment' || t.Transaction_Sub_Type__c == null){
                        JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t, mapAccountingPeriod,transactionCustomSettingMap.get('Close Reserve LAE').Debit_GL__c,transactionCustomSettingMap.get('Close Reserve LAE').Credit_GL__c));
                        //accountPayableLinesMapToInsert.put(noOfTransactions, createAPLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('LAE Payment').Debit_GL__c).Id));
                        journalLineItemList = journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Close Reserve LAE').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Close Reserve LAE').Credit_GL__c).Id);
                        if(t.Amount__c < 0){
                            journalLineItemList.addAll(journalLineItems(t, t.GL_Account_Name__c, mapOfGlAccounts.get(Label.Main_Cash_GL).Id,0));
                        }
                        if(t.Policy_Id__r.Treaty_Version__r.Reinsurance_Limit__c + t.Claim_Id__r.Per_Claim_Deductible__c < (t.Claim_Id__r.GL_5030__c + t.Claim_Id__r.GL_5000__c) ){
                            Decimal totalCeded = (t.Claim_Id__r.GL_5030__c + t.Claim_Id__r.GL_5000__c) - (t.Policy_Id__r.Treaty_Version__r.Reinsurance_Limit__c + t.Claim_Id__r.Per_Claim_Deductible__c);
                            Decimal currentCeded = (totalCeded - t.Amount__c) > t.Amount__c ? t.Amount__c : totalCeded;
                            journalLineItemList.addAll(journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Reserve LAE').Credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Reserve LAE').Debit_GL__c).Id,0));
                            journalLineItemList.addAll(journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Reserve LAE Payment').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Reserve LAE Payment').Credit_GL__c).Id,0));
                        }
                        JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                    }   
                }
                else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Loss Payment'){
                    //accountPayableMapToInsert.put(noOfTransactions, createAccountsPayable(t, mapAccountingPeriod));
                    
                    list<AcctSeed__Journal_Entry_Line__c> journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>(); 
                    if(t.Transaction_Sub_Type__c == 'Loss Payment' || t.Transaction_Sub_Type__c == null){
                        JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t, mapAccountingPeriod,transactionCustomSettingMap.get('Close Reserve Loss').Debit_GL__c,transactionCustomSettingMap.get('Close Reserve Loss').Credit_GL__c));
                        //accountPayableLinesMapToInsert.put(noOfTransactions, createAPLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('LAE Payment').Credit_GL__c).Id));
                        journalLineItemList = journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Close Reserve Loss').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Close Reserve Loss').Credit_GL__c).Id);
                        if(t.Amount__c < 0){
                            journalLineItemList.addAll(journalLineItems(t, t.GL_Account_Name__c, mapOfGlAccounts.get(Label.Main_Cash_GL).Id));
                        }
                        if(t.Policy_Id__r.Treaty_Version__r.Reinsurance_Limit__c + t.Claim_Id__r.Per_Claim_Deductible__c < (t.Claim_Id__r.GL_5030__c + t.Claim_Id__r.GL_5000__c) ){
                            Decimal totalCeded = (t.Claim_Id__r.GL_5030__c + t.Claim_Id__r.GL_5000__c) - (t.Policy_Id__r.Treaty_Version__r.Reinsurance_Limit__c + t.Claim_Id__r.Per_Claim_Deductible__c);
                            Decimal currentCeded = (totalCeded - t.Amount__c) > t.Amount__c ? t.Amount__c : totalCeded;
                            journalLineItemList.addAll(journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Reserve Loss').Credit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Reserve Loss').Debit_GL__c).Id,0));
                            journalLineItemList.addAll(journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Reserve Loss Payment').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Ceded Reserve Loss Payment').Credit_GL__c).Id,0));
                        }
                        JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                    }
                }
                else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Deductible Loss'){
                    //accountPayableMapToInsert.put(noOfTransactions, createAccountsPayable(t, mapAccountingPeriod));
                    
                    if(t.Transaction_Sub_Type__c == 'Loss Deductible' || t.Transaction_Sub_Type__c == null){
                        //accountPayableLinesMapToInsert.put(noOfTransactions, createAPLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('LAE Payment').Credit_GL__c).Id));
                    }
                }
                else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Deductible Expense'){
                    //accountPayableMapToInsert.put(noOfTransactions, createAccountsPayable(t, mapAccountingPeriod));
                    
                    if(t.Transaction_Sub_Type__c == 'LAE Deductible' || t.Transaction_Sub_Type__c == null){
                        //accountPayableLinesMapToInsert.put(noOfTransactions, createAPLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('LAE Payment').debit_GL__c).Id));
                    }
                }
                /*  else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Deductible Expense'){
JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t, mapAccountingPeriod));

list<AcctSeed__Journal_Entry_Line__c> journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>();
if(t.Transaction_Sub_Type__c == 'Deductible Expense LAE'){
journalLineItemList = journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Close Reserve LAE').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Close Reserve LAE').Credit_GL__c).Id);
JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
}
else if(t.Transaction_Sub_Type__c == 'Deductible Expense Loss'){
journalLineItemList = journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Close Reserve Loss').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Close Reserve Loss').Credit_GL__c).Id);
JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
}

}
*/
                else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Reopen Reserve'){
                    
                    list<AcctSeed__Journal_Entry_Line__c> journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>();
                    if(t.Transaction_Sub_Type__c == 'Re-Open Reserve LAE'){
                        JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t, mapAccountingPeriod,transactionCustomSettingMap.get('Open Reserve LAE').Debit_GL__c,transactionCustomSettingMap.get('Open Reserve LAE').Credit_GL__c));
                        journalLineItemList = journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Open Reserve LAE').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Open Reserve LAE').Credit_GL__c).Id);
                        JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                    }
                    else if(t.Transaction_Sub_Type__c == 'Re-Open Reserve Loss'){
                        JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t, mapAccountingPeriod,transactionCustomSettingMap.get('Open Reserve Loss').Debit_GL__c,transactionCustomSettingMap.get('Open Reserve Loss').Credit_GL__c));
                        journalLineItemList = journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Open Reserve Loss').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Open Reserve Loss').Credit_GL__c).Id);
                        JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                    }
                    
                }
                else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Unallocated LAE Payment'){
                    if(t.Amount__c < 0){
                        //JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t, mapAccountingPeriod));
                        JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t, mapAccountingPeriod,t.GL_Account_Name__c,Label.Main_Cash_GL));
                        //accountPayableMapToInsert.put(noOfTransactions, createAccountsPayable(t, mapAccountingPeriod));
                        list<AcctSeed__Journal_Entry_Line__c> journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>();
                        //if(t.Transaction_Sub_Type__c == 'Unallocated LAE Payment'){
                        //accountPayableLinesMapToInsert.put(noOfTransactions, createAPLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('LAE Payment').Debit_GL__c).Id));
                        //journalLineItemList = journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('LAE Payment').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('LAE Payment').Credit_GL__c).Id);
                        
                        journalLineItemList.addAll(journalLineItems(t, t.GL_Account_Name__c, mapOfGlAccounts.get(Label.Main_Cash_GL).Id,0));
                        JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                    }
                }
                else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'User Reserve'){
                    
                    
                    
                    list<AcctSeed__Journal_Entry_Line__c> journalLineItemList = new list<AcctSeed__Journal_Entry_Line__c>();
                    if(t.Transaction_Sub_Type__c == 'User Reserve LAE'){
                        JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t, mapAccountingPeriod,transactionCustomSettingMap.get('Open Reserve LAE').Debit_GL__c,transactionCustomSettingMap.get('Open Reserve LAE').Credit_GL__c));
                        journalLineItemList = journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Open Reserve LAE').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Open Reserve LAE').Credit_GL__c).Id);
                        JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                    }
                    else if(t.Transaction_Sub_Type__c == 'User Reserve Loss'){
                        JournalEntryMapToInsert.put(noOfTransactions, createJournalEntry(t, mapAccountingPeriod,transactionCustomSettingMap.get('Open Reserve Loss').Debit_GL__c,transactionCustomSettingMap.get('Open Reserve Loss').Credit_GL__c));
                        journalLineItemList = journalLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('Open Reserve Loss').Debit_GL__c).Id, mapOfGlAccounts.get(transactionCustomSettingMap.get('Open Reserve Loss').Credit_GL__c).Id);
                        JournalEntryLineItemsMapToInsert.put(noOfTransactions, journalLineItemList);
                    }
                    
                    
                    
                }
                /*else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Cash Payment'){
accountPayableMapToInsert.put(noOfTransactions, createAccountsPayable(t, mapAccountingPeriod));

if(t.Transaction_Sub_Type__c == 'LAE Payment' || t.Transaction_Sub_Type__c == null){
accountPayableLinesMapToInsert.put(noOfTransactions, createAPLineItems(t, mapOfGlAccounts.get(transactionCustomSettingMap.get('LAE Payment').Debit_GL__c).Id));
}
}*/
                
                
            }
            //----inserting billings
             System.debug('bilsnsnd'+billingMapToInsert);
            if(billingMapToInsert != null && !billingMapToInsert.isEmpty()){
                insert billingMapToInsert.values();
            }
            System.debug('bilsnsnd'+billingMapToInsert);
            if(billingMapToInsert != null && !billingMapToInsert.isEmpty()){
                system.debug('==billSchedulesMap=='+billSchedulesMap);
                list<AcctSeed__Billing_Line__c> billLineItemListToInsert = new list<AcctSeed__Billing_Line__c>();
                //for(AcctSeed__Billing_Line__c li : lineItemMapToInsert.values()){
                if(billingMapToInsert != null){
                    for(Integer i : billingMapToInsert.keySet()){
                        if(lineItemMapToInsert.containsKey(i)){
                            for(AcctSeed__Billing_Line__c li : lineItemMapToInsert.get(i)){
                                li.AcctSeed__Billing__c = billingMapToInsert.get(i).Id;
                                billLineItemListToInsert.add(li);
                            }
                        }
                    }
                }
                insert billLineItemListToInsert;
                AcctSeed.PostResult[] postResults = AcctSeed.BillingPostService.postBillings(billingMapToInsert.values());
                Set<Id> billingIdToSendEmail = new Set<Id>();
                
                /*for (AcctSeed.PostResult theResult : postResults) {
                    if (theResult.isSuccess) {
                        
                    } 
                }*/
                if(!noPaymentRecievedTransaction.isEmpty()){
                    for(Integer inst : noPaymentRecievedTransaction){
                        billingIdToSendEmail.add(billingMapToInsert.get(inst).Id);
                    }
                }
                if(!policyToUpdateMap.isEmpty()){
                    for(Integer inst : policyToUpdateMap.keySet()){
                        Policy__c pol = new Policy__c();
                        pol.Id = policyToUpdateMap.get(inst);
                        if(policyToUpdate.containsKey(policyToUpdateMap.get(inst))){
                            pol = policyToUpdate.get(policyToUpdateMap.get(inst));
                        }
                        pol.Billing__c = billingMapToInsert.get(inst).Id;
                        policyToUpdate.put(policyToUpdateMap.get(inst),pol);
                    }
                }
                // List<Messaging.SingleEmailMessage> masterListMails =   new List<Messaging.SingleEmailMessage>();
                if(!billingIdToSendEmail.isEmpty()){
                    createEmailMessage(billingIdToSendEmail, owea.Id);
                    /*
Map<Id, PAgeReference> pageReferenceMAp = new Map<Id, PAgeReference>();
Map<Id,AcctSeed__Billing__c> billingMap = new  Map<Id,AcctSeed__Billing__c>();
List<Messaging.SingleEmailMessage> masterListMails = new List<Messaging.SingleEmailMessage>();
for(AcctSeed__Billing__c inst : [select Id,AcctSeed__Billing_Contact__c,AcctSeed__PDF_Email_Status__c,AcctSeed__Billing_Contact__r.Email, AcctSeed__Billing_Format__r.Name,
AcctSeed__Billing_Format__r.AcctSeed__Default_Email_Template__c, 
AcctSeed__Billing_Format__r.AcctSeed__Visualforce_PDF_Page__c
from AcctSeed__Billing__c where id in:billingIdToSendEmail  ]){
billingMap.put(inst.Id,inst);

// getEmailAttachments(inst.Id,inst.AcctSeed__Billing_Format__r.AcctSeed__Visualforce_PDF_Page__c);                                  

System.debug(policyAttachMap);                                

if(createEmailMessage(inst.Id,inst.AcctSeed__Billing_Contact__r.Email,
inst.AcctSeed__Billing_Format__r.AcctSeed__Default_Email_Template__c,
inst.AcctSeed__Billing_Format__r.AcctSeed__Visualforce_PDF_Page__c, 
owea.Id,inst.AcctSeed__Billing_Contact__c) != null){

Messaging.SingleEmailMessage message = createEmailMessage(inst.Id,inst.AcctSeed__Billing_Contact__r.Email,
inst.AcctSeed__Billing_Format__r.AcctSeed__Default_Email_Template__c,
inst.AcctSeed__Billing_Format__r.AcctSeed__Visualforce_PDF_Page__c, 
owea.Id,inst.AcctSeed__Billing_Contact__c);

System.debug('Shsjsjs'+message);
masterListMails.add(message);

}

}
*/
                }
                // Messaging.sendEmail(masterListMails);
                
            }
            
            list<AcctSeed__Scheduled_Revenue_Expense__c> schedulesListToInsert = new list<AcctSeed__Scheduled_Revenue_Expense__c>();
            if(schedules.size()>0){
                /*
                for(AcctSeed__Scheduled_Revenue_Expense__c inst : schedules ){
                   // inst.AcctSeed__Ledger__c = ledger.Id;
                }
	           */
                schedulesListToInsert.addAll(schedules);
            }
            
            if(billSchedulesMap != null && !billSchedulesMap.isEmpty()){
                system.debug('***noOfTransactions--'+noOfTransactions);
                for(integer i = 1; i < = noOfTransactions; i ++ ){
                    if(billSchedulesMap.containsKey(i)){
                        system.debug('***billSchedulesMap.get--'+billSchedulesMap.get(i));
                        for(AcctSeed__Scheduled_Revenue_Expense__c a : billSchedulesMap.get(i)){
                            a.AcctSeed__Billing__c = billingMapToInsert.get(i).Id;
                            
                            schedulesListToInsert.add(a);
                        }
                    }
                }
            }
            if(schedulesListToInsert.size() > 0){
                insert schedulesListToInsert;
            }
            if(JournalEntryMapToInsert != null && !JournalEntryMapToInsert.isEmpty()){
                /*
                for(AcctSeed__Journal_Entry__c inst : JournalEntryMapToInsert.values()){
                    inst.AcctSeed__Ledger__c = ledger.id;
                }
                */
                insert JournalEntryMapToInsert.values();
                
                //-----linking journal entry line items to parent and inserting
                list<AcctSeed__Journal_Entry_Line__c> journalLineItemListToInsert = new list<AcctSeed__Journal_Entry_Line__c>();
                system.debug('==JournalEntryLineItemsMapToInsert=='+JournalEntryLineItemsMapToInsert.keyset());
                for(integer i = 1; i < = noOfTransactions; i ++ ){
                    if(JournalEntryLineItemsMapToInsert.containsKey(i)){
                        for(AcctSeed__Journal_Entry_Line__c li : JournalEntryLineItemsMapToInsert.get(i)){
                            if(JournalEntryMapToInsert != null && JournalEntryMapToInsert.containsKey(i)){
                                li.AcctSeed__Journal_Entry__c = JournalEntryMapToInsert.get(i).Id;
                                
                                journalLineItemListToInsert.add(li);
                            }
                            
                        }
                    }
                }
                
                if(journalLineItemListToInsert != null && !journalLineItemListToInsert.isEmpty())
                    insert journalLineItemListToInsert;
                AcctSeed.PostResult[] postResults = AcctSeed.JournalEntryPostService.postJournalEntries(JournalEntryMapToInsert.values());
            }
            
            if(accountPayableMapToInsert != null && !accountPayableMapToInsert.isEmpty()){
                upsert accountPayableMapToInsert.values();
                
                list<AcctSeed__Account_Payable_Line__c> APLinesListToInsert = new list<AcctSeed__Account_Payable_Line__c>();
                
                if(accountPayableLinesMapToInsert != null && !accountPayableLinesMapToInsert.isEmpty()){
                    for(integer i = 1; i < = noOfTransactions; i ++ ){
                        if(accountPayableLinesMapToInsert.containsKey(i) && accountPayableMapToInsert.containsKey(i)){
                            AcctSeed__Account_Payable_Line__c al = accountPayableLinesMapToInsert.get(i);
                            al.AcctSeed__Account_Payable__c = accountPayableMapToInsert.get(i).Id;
                            APLinesListToInsert.add(al);
                        }
                    }
                    
                }
                if(!APLinesListToInsert.isEmpty()){
                    insert APLinesListToInsert;
                    //AcctSeed.PostResult[] postResults = AcctSeed.AccountPayablePostService.postAccountPayables(accountPayableMapToInsert.values());
                }
                
            }
            
            if(!PolicyClaimMap.isEmpty()){
                update PolicyClaimMap.values();
            }
            
            if(!endorsementToUpdate.isEmpty()){
                update endorsementToUpdate.values();
            }
            
            if(!policyToUpdate.isEmpty()){
                update policyToUpdate.values();
            }
            
        }catch(Exception e){
            Database.rollback(sp);
            system.debug('----Exception is '+e.getLineNumber()+e.getMessage());
            system.debug('----Exception is '+e.getStackTraceString());
            Messaging.SingleEmailMessage message = new Messaging.SingleEmailMessage();
            message.toAddresses = Label.System_Admin_Emails.split(',');
            message.subject = 'Error While Processing Accounting Seed Transactions';
            message.plainTextBody = 'Team,\n\nFollowing error has occurred while processing the transactions\n\n '+e.getMessage() + '\n\n'+e.getStackTraceString() + '\n\n\nInputTransacitons' + transactionJson;
            Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
                Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
            
        }
    }
    
    /*
@future(callout = true)
public Static void getEmailAttachments(Id billId,String pdfAttachmentName){
try{
PageReference pdf = new pagereference('/apex/'+pdfAttachmentName);
// add parent id to the parameters for standardcontroller
pdf.getParameters().put('id',billId);
// the contents of the attachment from the pdf
Blob body;
pdf.setRedirect(true);
body = pdf.getContentasPdf();

Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
attach.setContentType('application/pdf');
attach.setFileName('attachment.pdf');
attach.setInline(false);
attach.Body = body;

policyAttachMap.put(billId,attach);

}
catch(Exception e){
System.debug(e.getMessage());
}
}
*/
    
    public static Map<String,Id> getAllEmailTemplates(){
        try{
            Map<String,Id> emailTemplateMap = new Map<String,Id>();
            List<EmailTemplate> emailTemplateList = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body
                                                     from EmailTemplate];
            
            for(EmailTemplate temp : emailTemplateList){
                emailTemplateMap.put(temp.developerName,temp.Id);
            }
            return emailTemplateMap;
        }
        catch(Exception e){
            System.debug(e.getMessage());
            return null;
        }
    }
    
    
    
    /*
@future(callout = true)
public static Messaging.SingleEmailMessage  createEmailMessage(Id billId,String toEmail, String EmailTemplateName,String pdfAttachmentName,Id oweaId,Id ContactId){
try{

for(AcctSeed__Billing__c inst : [select Id,AcctSeed__Billing_Contact__c,AcctSeed__PDF_Email_Status__c,AcctSeed__Billing_Contact__r.Email, AcctSeed__Billing_Format__r.Name,
AcctSeed__Billing_Format__r.AcctSeed__Default_Email_Template__c, 
AcctSeed__Billing_Format__r.AcctSeed__Visualforce_PDF_Page__c
from AcctSeed__Billing__c where id in:billingIdToSendEmail  ]){
PageReference pdf = new pagereference('/apex/'+pdfAttachmentName);
// add parent id to the parameters for standardcontroller
pdf.getParameters().put('id',billId);
// the contents of the attachment from the pdf
Blob body;
pdf.setRedirect(true);
body = pdf.getContentasPdf();

Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
attach.setContentType('application/pdf');
attach.setFileName('attachment.pdf');
attach.setInline(false);
attach.Body = body;                     
}
/*
PageReference pdf = new pagereference('/apex/'+pdfAttachmentName);
// add parent id to the parameters for standardcontroller
pdf.getParameters().put('id',billId);
// the contents of the attachment from the pdf
Blob body;
pdf.setRedirect(true);
body = pdf.getContentasPdf();

Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
attach.setContentType('application/pdf');
attach.setFileName('attachment.pdf');
attach.setInline(false);
attach.Body = body;

Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
message.setTargetObjectId(contactId); 
message.setSaveAsActivity(true);
// message.setReplyTo('no-reply@company.com');
message.setUseSignature(false); 
message.setBccSender(false); 
message.setSaveAsActivity(true); 
message.setFileAttachments(new Messaging.EmailFileAttachment[] { policyAttachMap.get(billId) }); 
/*EmailTemplate emailTemplate = [Select Id,Subject,Description,HtmlValue,DeveloperName,Body
from EmailTemplate where DeveloperName =: EmailTemplateName];
message.setOrgWideEmailAddressId(oweaId);
message.setTemplateID(emailTemplateMap.get(EmailTemplateName)); 
message.setWhatId(billId); 
message.toAddresses = new String[] {toEmail};
// Messaging.SingleEmailMessage[] messages =   new List<Messaging.SingleEmailMessage> {message};
//Messaging.SendEmailResult[] results = Messaging.sendEmail(messages);
/*
for (Messaging.SendEmailResult mr : results) 
{
if (mr.isSuccess()) {
AcctSeed__Billing__c bill = [SELECT Id,AcctSeed__PDF_Email_Status__c 
from AcctSeed__Billing__c where id =: billId];
bill.AcctSeed__PDF_Email_Status__c = 'Sent';

update bill;
}  else {
// Operation failed, so get all errors                
for(Messaging.SendEmailError err : mr.getErrors()) {
System.debug('The following error has occurred.');                    
System.debug(err.getStatusCode() + ': ' + err.getMessage());
System.debug('fields that affected this error: ' + err.getFields());
}
}
}

return message;
}
catch(Exception e){
System.debug(e.getMessage() + e.getLineNumber());
return null;
}
}
*/
    
    @future(callout = true)
    public static void  createEmailMessage(Set<Id> billingIdToSendEmail, Id oweaId){
        try{
            List<ContentVersion> attachmentList = new List<ContentVersion>();
            Map<String,Id>  emailTemplateMap =   getAllEmailTemplates();
            List<Messaging.SingleEmailMessage> masterListMails = new List<Messaging.SingleEmailMessage>();
            for(AcctSeed__Billing__c inst : [select Id,Name,AcctSeed__Customer__r.Name,AcctSeed__Billing_Contact__c,AcctSeed__PDF_Email_Status__c,AcctSeed__Billing_Contact__r.Email, AcctSeed__Billing_Format__r.Name,
                                             AcctSeed__Billing_Format__r.AcctSeed__Default_Email_Template__c, 
                                             AcctSeed__Billing_Format__r.AcctSeed__Visualforce_PDF_Page__c
                                             from AcctSeed__Billing__c where id in:billingIdToSendEmail  ]){
                                                 
                                                 
                                                 PageReference pdf = new pagereference('/apex/'+inst.AcctSeed__Billing_Format__r.AcctSeed__Visualforce_PDF_Page__c);
                                                 // add parent id to the parameters for standardcontroller
                                                 pdf.getParameters().put('id',inst.Id);
                                                 // the contents of the attachment from the pdf
                                                 Blob body;
                                                 pdf.setRedirect(true);
                                                 
                                                 if(test.isRunningTest()){
                                                     body = blob.valueOf('test');
                                                 }else{
                                                     body = pdf.getContentasPdf();
                                                 }
                                                 
                                                 Messaging.EmailFileAttachment attach = new Messaging.EmailFileAttachment();
                                                 attach.setContentType('application/pdf');
                                                 attach.setFileName('attachment.pdf');
                                                 attach.setInline(false);
                                                 attach.Body = body;   
                                                 
                                                 Messaging.SingleEmailMessage message = new  Messaging.SingleEmailMessage();
                                                 message.setTargetObjectId(inst.AcctSeed__Billing_Contact__c); 
                                                 message.setSaveAsActivity(true);
                                                 // message.setReplyTo('no-reply@company.com');
                                                 message.setUseSignature(false); 
                                                 message.setBccSender(false); 
                                                 message.setSaveAsActivity(true); 
                                                 message.setFileAttachments(new Messaging.EmailFileAttachment[] { attach }); 
                                                 
                                                 message.setOrgWideEmailAddressId(oweaId);
                                                 message.setTemplateID(emailTemplateMap.get(inst.AcctSeed__Billing_Format__r.AcctSeed__Default_Email_Template__c)); 
                                                 message.setWhatId(inst.Id); 
                                                 message.toAddresses = new String[] {inst.AcctSeed__Billing_Contact__r.Email};
                                                     
                                                     masterListMails.add(message);
                                                 
                                                 
                                                 ContentVersion cv = new ContentVersion();
                                                 cv.Title = inst.AcctSeed__Customer__r.Name +'_Inv#_'+inst.Name+'.pdf';
                                                 cv.PathOnClient = inst.AcctSeed__Customer__r.Name +'_Inv#_'+inst.Name+'.pdf';
                                                 cv.FirstPublishLocationId = inst.id;
                                                 cv.VersionData = body;
                                                 attachmentList.add(cv);
                                             }
            
            
            Messaging.SendEmailResult[] results = Messaging.sendEmail(masterListMails);
            
            
            for (Messaging.SendEmailResult mr : results) 
            {
                if (mr.isSuccess()) {
                    System.debug('mrrr'+mr);
                }  else {
                    // Operation failed, so get all errors                
                    for(Messaging.SendEmailError err : mr.getErrors()) {
                        System.debug('The following error has occurred.');                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                        System.debug('fields that affected this error: ' + err.getFields());
                    }
                }
            }
            
            if(!attachmentList.isEmpty()){
                insert attachmentList;
            }
            
        }
        catch(Exception e){
            System.debug(e.getMessage() + e.getLineNumber());
            
        }
    }
    
    public static list<AcctSeed__Journal_Entry_Line__c> journalLineItems(AS_Transaction__c t, string debitGL, string creditGL){
        Date transactionDate = t.Policy_Id__r.GL_Processing_Date__c != null ? t.Policy_Id__r.GL_Processing_Date__c :  (t.Policy_Id__r.Effective_Date__c >= System.today() ? t.Policy_Id__r.Effective_Date__c : System.today());
            
            if(t.Claim_Id__c != null){
                transactionDate = (t.Policy_Claim_Detail__r.Date__c != null ? t.Policy_Claim_Detail__r.Date__c : Date.valueOf(t.CreatedDate));
            }
        
        if(t.Policy_Endorsement_Id__c != null){
            transactionDate = t.Policy_Endorsement_Id__r.GL_Processing_Date__c != null ? t.Policy_Endorsement_Id__r.GL_Processing_Date__c :  (t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c >= System.today() ? t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c : System.today());
                if(t.Transaction_Type__c == 'ERE' && t.Amount__c < 0){
                    transactionDate = System.today();
                }
                }
        
        list<AcctSeed__Journal_Entry_Line__c> tempList = new list<AcctSeed__Journal_Entry_Line__c>();
        
        //-----creating debit journal line item
        AcctSeed__Journal_Entry_Line__c debitJLItem = new AcctSeed__Journal_Entry_Line__c();
        debitJLItem.AcctSeed__Account__c = t.Firm_Id__c;
        debitJLItem.AcctSeed__Units__c = 1;
        debitJLItem.AcctSeed__Date__c = transactionDate;
        
        if(t.Amount__c < 0){
            debitJLItem.AcctSeed__GL_Account__c = creditGL;
            debitJLItem.AcctSeed__Debit__c = -(t.Amount__c);
        }else{
            debitJLItem.AcctSeed__GL_Account__c = debitGL;
            debitJLItem.AcctSeed__Debit__c = t.Amount__c;
        }
        
        //-----creating credit journal line item
        AcctSeed__Journal_Entry_Line__c creditJLItem = new AcctSeed__Journal_Entry_Line__c();
        creditJLItem.AcctSeed__Account__c = t.Firm_Id__c;
        creditJLItem.AcctSeed__Units__c = 1;
        creditJLItem.AcctSeed__Date__c = transactionDate;
        
        if(t.Amount__c < 0){
            creditJLItem.AcctSeed__GL_Account__c = debitGL;
            creditJLItem.AcctSeed__Credit__c = -(t.Amount__c);
        }else{
            creditJLItem.AcctSeed__GL_Account__c = creditGL;
            creditJLItem.AcctSeed__Credit__c = t.Amount__c;
        }
        
        
        tempList.add(debitJLItem);
        tempList.add(creditJLItem);
        return tempList;
    }
    
    public static list<AcctSeed__Journal_Entry_Line__c> journalLineItems(AS_Transaction__c t, string debitGL, string creditGL,Decimal amount){
        
        Date transactionDate = t.Policy_Id__r.GL_Processing_Date__c != null ? t.Policy_Id__r.GL_Processing_Date__c :  (t.Policy_Id__r.Effective_Date__c >= System.today() ? t.Policy_Id__r.Effective_Date__c : System.today());
            
            if(t.Claim_Id__c != null){
                transactionDate = (t.Policy_Claim_Detail__r.Date__c != null ? t.Policy_Claim_Detail__r.Date__c : Date.valueOf(t.CreatedDate));
            }
        
        if(t.Policy_Endorsement_Id__c != null){
            transactionDate = t.Policy_Endorsement_Id__r.GL_Processing_Date__c != null ? t.Policy_Endorsement_Id__r.GL_Processing_Date__c :  (t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c >= System.today() ? t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c : System.today());
                if(t.Transaction_Type__c == 'ERE' && t.Amount__c < 0){
                    transactionDate = System.today();
                }
                }
        
        list<AcctSeed__Journal_Entry_Line__c> tempList = new list<AcctSeed__Journal_Entry_Line__c>();
        
        //-----creating debit journal line item
        AcctSeed__Journal_Entry_Line__c debitJLItem = new AcctSeed__Journal_Entry_Line__c();
        debitJLItem.AcctSeed__Account__c = t.Firm_Id__c;
        debitJLItem.AcctSeed__Units__c = 1;
        debitJLItem.AcctSeed__Date__c = transactionDate;
        
        if(amount < 0){
            debitJLItem.AcctSeed__GL_Account__c = creditGL;
            debitJLItem.AcctSeed__Debit__c = -(amount);
        }else{
            debitJLItem.AcctSeed__GL_Account__c = debitGL;
            debitJLItem.AcctSeed__Debit__c = amount;
        }
        
        //-----creating credit journal line item
        AcctSeed__Journal_Entry_Line__c creditJLItem = new AcctSeed__Journal_Entry_Line__c();
        creditJLItem.AcctSeed__Account__c = t.Firm_Id__c;
        creditJLItem.AcctSeed__Units__c = 1;
        creditJLItem.AcctSeed__Date__c = transactionDate;
        
        if(amount < 0){
            creditJLItem.AcctSeed__GL_Account__c = debitGL;
            creditJLItem.AcctSeed__Credit__c = -(amount);
        }else{
            creditJLItem.AcctSeed__GL_Account__c = creditGL;
            creditJLItem.AcctSeed__Credit__c = amount;
        }
        
        
        tempList.add(debitJLItem);
        tempList.add(creditJLItem);
        return tempList;
    }
    
    public static AcctSeed__Journal_Entry_Line__c journalLineItem(AS_Transaction__c t, String operationType, String glAccount,Decimal amount){
        
        Date transactionDate = t.Policy_Id__r.GL_Processing_Date__c != null ? t.Policy_Id__r.GL_Processing_Date__c :  (t.Policy_Id__r.Effective_Date__c >= System.today() ? t.Policy_Id__r.Effective_Date__c : System.today());
            
            if(t.Claim_Id__c != null){
                transactionDate = (t.Policy_Claim_Detail__r.Date__c != null ? t.Policy_Claim_Detail__r.Date__c : Date.valueOf(t.CreatedDate));
            }
        
        if(t.Policy_Endorsement_Id__c != null){
            transactionDate = t.Policy_Endorsement_Id__r.GL_Processing_Date__c != null ? t.Policy_Endorsement_Id__r.GL_Processing_Date__c :  (t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c >= System.today() ? t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c : System.today());
                if(t.Transaction_Type__c == 'ERE' && t.Amount__c < 0){
                    transactionDate = System.today();
                }
                }
        
        //-----creating debit journal line item
        AcctSeed__Journal_Entry_Line__c line = new AcctSeed__Journal_Entry_Line__c();
        line.AcctSeed__Account__c = t.Firm_Id__c;
        line.AcctSeed__Units__c = 1;
        line.AcctSeed__Date__c = transactionDate;
        if((operationType == 'Debit' && amount >0) || (operationType == 'Credit' && amount < 0)){
            line.AcctSeed__GL_Account__c = glAccount;
            line.AcctSeed__Debit__c = Math.abs(amount);
        }else if((operationType == 'Credit' && amount >0) || (operationType == 'Debit' && amount < 0)){
            line.AcctSeed__GL_Account__c = glAccount;
            line.AcctSeed__Credit__c = Math.abs(amount);
        }
        return line;
    }
    
    public static AcctSeed__Journal_Entry__c createJournalEntry(AS_Transaction__c t, map<string,AcctSeed__Accounting_Period__c> mapAccountingPeriod,String glDebitAccount,String glCreditAccount){
        Date transactionDate = t.Policy_Id__r.GL_Processing_Date__c != null ? t.Policy_Id__r.GL_Processing_Date__c :  (t.Policy_Id__r.Effective_Date__c >= System.today() ? t.Policy_Id__r.Effective_Date__c : System.today());
            
            if(t.Claim_Id__c != null){
                transactionDate = (t.Policy_Claim_Detail__r.Date__c != null ? t.Policy_Claim_Detail__r.Date__c : Date.valueOf(t.CreatedDate));
            }
        
        if(t.Policy_Endorsement_Id__c != null){
            transactionDate = t.Policy_Endorsement_Id__r.GL_Processing_Date__c != null ? t.Policy_Endorsement_Id__r.GL_Processing_Date__c :  (t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c >= System.today() ? t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c : System.today());
                if(t.Transaction_Type__c == 'ERE' && t.Amount__c < 0){
                    transactionDate = System.today();
                }
        }
        
        AcctSeed__Journal_Entry__c je = new AcctSeed__Journal_Entry__c();
        je.AcctSeed__Journal_Date__c = transactionDate;
        je.AS_Transaction__c = t.Id;
        je.GL_Credit_Account__c=glCreditAccount;
        je.GL_Debit_Account__c=glDebitAccount;
        string acKey1 = 'key'+transactionDate.month()+'year'+transactionDate.year();
        if(mapAccountingPeriod != null && mapAccountingPeriod.containsKey(acKey1)){
            je.AcctSeed__Accounting_Period__c = mapAccountingPeriod.get(acKey1).Id;
        }
        
        string nameJe = 'JE';
        
        if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Open Reserve'){
            
            if(t.Transaction_Sub_Type__c == 'Open Reserve LAE'){
                nameJe = 'LAE Open Reserve';
            }
            else if(t.Transaction_Sub_Type__c == 'Open Reserve Loss'){
                nameJe = 'Loss Open Reserve';
            }
            
        }
        else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Close Reserve'){
            
            if(t.Transaction_Sub_Type__c == 'Close Reserve LAE'){
                nameJe = 'LAE Close Reserve';
            }
            else if(t.Transaction_Sub_Type__c == 'Close Reserve Loss'){
                nameJe = 'Loss Close Reserve';
            }
            
        }
        else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'User Reserve'){
            
            if(t.Transaction_Sub_Type__c == 'User Reserve LAE'){
                nameJe = 'LAE Change Reserve';
            }
            else if(t.Transaction_Sub_Type__c == 'User Reserve Loss'){
                nameJe = 'Loss Change Reserve';
            }
            
        }
        else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Change in Ceded LAE Reserve'){
            
            nameJe = 'LAE Reserve';
            
        }
        else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Change in Ceded Loss Reserve'){
            
            nameJe = 'Loss Reserve';
            
        }
        else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Claim Coverage - ARDC'){
            
            nameJe = 'Loss Reserve';
            
        }
        else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'LAE Payment'){
            
            nameJe = 'LAE Payment';
            
        }
        else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Loss Payment'){
            
            nameJe = 'Loss Payment';
            
        }
        else if(t.Transaction_Type__c != null && t.Transaction_Type__c == 'Reopen Reserve'){
            
            if(t.Transaction_Sub_Type__c == 'Re-Open Reserve LAE'){
                nameJe = 'LAE Reopen Reserve';
            }
            else if(t.Transaction_Sub_Type__c == 'Re-Open Reserve Loss'){
                nameJe = 'Loss Reopen Reserve';
            }
            
        }
        if(t.Claim_Id__c != null && PolicyClaimMap.containsKey(t.Claim_Id__c)){
            
            Policy_Claim__c claim = PolicyClaimMap.get(t.Claim_Id__c);
            
            if(claim.JE_Entry_Name_Number__c == null){
                
                claim.JE_Entry_Name_Number__c = 0;
                
            } else {
                claim.JE_Entry_Name_Number__c = claim.JE_Entry_Name_Number__c + 1;
            }
            
            je.Name = nameJe+'-'+claim.Name+'-'+String.valueOf(claim.JE_Entry_Name_Number__c);
            
            PolicyClaimMap.put(claim.Id,claim);
            
        } else {
            
            je.Name = nameJe+' - 001';
        }
        
        je.Firm__c = t.Firm_Id__c;
        
        if(t.Claim_Id__c != null){
            je.Claim__c = t.Claim_Id__c;
        }
        
        if(t.Policy_Claim_Detail__c != null){
            je.Policy_Claim_Detail__c = t.Policy_Claim_Detail__c;
        }
        
        if(t.Policy_Id__c != null){
            je.Policy__c = t.Policy_Id__c;
        }
        
        if(t.Policy_Endorsement_Id__c != null){
            je.Policy_Endorsement__c = t.Policy_Endorsement_Id__c;
        }
        
        return je;
        
    }
    
    //-------params:
    //------billType represents True for positive bill, and false for negitive bill
    //------t represents the transaction from which we have to create the bill and bill line items
    
    public static AcctSeed__Billing_Line__c createBillingLineItem(Decimal amount, boolean billType, string debitGL, string creditGL){
        AcctSeed__Billing_Line__c li = new AcctSeed__Billing_Line__c();
        li.AcctSeed__Rate__c = amount;
        if(billType){
            li.AcctSeed__Revenue_GL_Account__c = creditGL;
            //li.AcctSeed__Expense_GL_Account__c = debitGL;
        }else{
            if(amount > 0){
                li.AcctSeed__Rate__c = -(amount);
            }
            
            li.AcctSeed__Revenue_GL_Account__c = debitGl;
            //li.AcctSeed__Expense_GL_Account__c = creditGL;
        }
        li.AcctSeed__Hours_Units__c = 1;
        
        return li;
    }
    
    
    
    public static AcctSeed__Billing__c createBilling(AS_Transaction__c t,Map<String,AcctSeed__Billing_Format__c> billingFormats){
        AcctSeed__Billing__c bill = createBilling(t);
        if(billingFormats.containsKey(Label.Policy_Premium_Billing_Format) && (t.Transaction_Type__c == 'Issue Policy')){
            bill.AcctSeed__Billing_Format__c = billingFormats.get(Label.Policy_Premium_Billing_Format).Id;
        }else if(billingFormats.containsKey(Label.Endorsement_Billing_Format) && (t.Transaction_Type__c == 'Add Lawyer' || t.Transaction_Type__c == 'Delete Lawyer' || t.Transaction_Type__c == 'ERE')){
            bill.AcctSeed__Billing_Format__c = billingFormats.get(Label.Endorsement_Billing_Format).Id;
        }
        
        return bill;
    }
    
    public static AcctSeed__Billing__c createBilling(AS_Transaction__c t){
        Date transactionDate = t.Policy_Id__r.GL_Processing_Date__c != null ? t.Policy_Id__r.GL_Processing_Date__c :  (t.Policy_Id__r.Effective_Date__c >= System.today() ? t.Policy_Id__r.Effective_Date__c : System.today());
            if(t.Policy_Endorsement_Id__c != null){
                transactionDate = t.Policy_Endorsement_Id__r.GL_Processing_Date__c != null ? t.Policy_Endorsement_Id__r.GL_Processing_Date__c :  (t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c >= System.today() ? t.Policy_Endorsement_Id__r.Endorsement_Effective_Date__c : System.today());
                    }
        
        AcctSeed__Billing__c tempBilling = new AcctSeed__Billing__c();
        tempBilling.Policy__c = t.Policy_Id__c;
        
        
        if(t.Policy_Endorsement_Id__c != null){
            tempBilling.Policy_Endorsement__c = t.Policy_Endorsement_Id__c;
        }
        
        tempBilling.AcctSeed__Customer__c = t.Firm_Id__c;
        //tempBilling.AcctSeed__Date__c = date.today();
        tempBilling.AcctSeed__Date__c = transactionDate;
        tempBilling.AS_Transaction__c = t.Id;
        
        if(t.Transaction_Type__c == 'Issue Policy'){
            tempBilling.Billing_Description__c = 'Policy Premium #' + t.Policy_Id__r.Name;
        }else if(t.Transaction_Type__c == 'Add Lawyer'){
            tempBilling.Billing_Description__c = 'Policy #' + t.Policy_Id__r.Name + ' - Add Lawyer - ' + t.Policy_Endorsement_Id__r.Lawyer__r.Name;
        }else if(t.Transaction_Type__c == 'Delete Lawyer'){
            tempBilling.Billing_Description__c = 'Policy #' + t.Policy_Id__r.Name + ' - Delete Lawyer - ' + t.Policy_Endorsement_Id__r.Lawyer_Name__c;  
        }else if(t.Transaction_Type__c == 'ERE'){
            tempBilling.Billing_Description__c = 'Extended Reporting Period Premium: Policy #' + t.Policy_Endorsement_Id__r.Policy__r.Name;
        }else if(t.Transaction_Type__c == 'Cancel Policy'){
            tempBilling.Billing_Description__c = 'Policy Cancel Credit #' + t.Policy_Endorsement_Id__r.Policy__r.Name;
        }
        //Policy_Id__r.Firm_Contact__c,Policy_Endorsement_Id__r.Lawyer_Name__c,Policy_Endorsement_Id__r.Lawyer__r.Name,Policy_Id__r.Name, Policy_Id__r.Account__r.AcctSeed__Billing_Contact__c 
        tempBilling.AcctSeed__Billing_Contact__c = (t.Policy_Id__r.Account__r.AcctSeed__Billing_Contact__c != null ? t.Policy_Id__r.Account__r.AcctSeed__Billing_Contact__c : t.Policy_Id__r.Firm_Contact__c);  
        
        if(t.Firm_Id__r.billingstreet != null){
            tempBilling.AcctSeed__Billing_Street__c = t.Firm_Id__r.billingstreet;
        }
        if(t.Firm_Id__r.billingstate != null){
            tempBilling.AcctSeed__Billing_State__c = t.Firm_Id__r.billingstate;
        }
        if(t.Firm_Id__r.billingCity != null){
            tempBilling.AcctSeed__Billing_City__c = t.Firm_Id__r.billingCity;
        }
        if(t.Firm_Id__r.billingPostalCode != null){
            tempBilling.AcctSeed__Billing_PostalCode__c = t.Firm_Id__r.billingPostalCode;
        }
        if(t.Firm_Id__r.BillingCountry != null){
            tempBilling.AcctSeed__Billing_Country__c = t.Firm_Id__r.BillingCountry;
        }
        
        
        
        /*tempBilling.AcctSeed__Shipping_Street__c = t.Firm_Id__r.shippingStreet;
tempBilling.AcctSeed__Shipping_City__c = t.Firm_Id__r.shippingCity;
tempBilling.AcctSeed__Shipping_State__c = t.Firm_Id__r.shippingState;
tempBilling.AcctSeed__Shipping_PostalCode__c = t.Firm_Id__r.shippingPostalCode;
tempBilling.AcctSeed__Shipping_Country__c = t.Firm_Id__r.shippingCountry;*/
        
        
        return tempBilling;
    }
    
}