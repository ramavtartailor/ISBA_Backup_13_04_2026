public class CreateEventAttendeeCmpController {

    @AuraEnabled
    public static CLE_Event__c getDetails(String recId){
        try {
            CLE_Event__c event = [SELECT Id, Name FROM CLE_Event__c WHERE Id=:recId];
            return event;
        } catch (Exception e) {
            throw new AuraHandledException(e.getMessage());
        }
    }
    
    public static List<String> handlerCommaWithinColumn(String csvLine){
        
        List<String> returnFields = new List<String>();
        String prevLine = csvLine;
        Integer startIndex;
        Integer endIndex;
        while(csvLine.indexOf('"') > -1){
            if(startIndex == null){
                startIndex = csvLine.indexOf('"');
                csvLine = csvLine.substring(0, startIndex) + ':quotes:' + csvLine.substring(startIndex+1, csvLine.length());
            }else{
                if(endIndex == null){
                    endIndex = csvLine.indexOf('"');
                    csvLine = csvLine.substring(0, endIndex) + ':quotes:' + csvLine.substring(endIndex+1, csvLine.length());
                }
            }
            if(startIndex != null && endIndex != null){
                String sub = csvLine.substring(startIndex, endIndex);
                sub = sub.replaceAll(',', ':comma:');
                csvLine = csvLine.substring(0, startIndex) + sub + csvLine.substring(endIndex, csvLine.length());
                startIndex = null;
                endIndex = null;
            }
        }
        
        for(String column : csvLine.split(',')){
            column = column.replaceAll(':quotes:', '').replaceAll(':comma:', ',');
            returnFields.add(column);
        }
        System.debug('returnFields'+returnFields);
        return returnFields;
    }
    
    @TestVisible    
    private static List<String> separateCommas(String input){
        List<String> results = input.split(',');
        for(String result : results) {
            result = result.trim();
        }
        return results;
    }
    
    @AuraEnabled
    public static csvWrapper getCSVObject(String csv_str) {
        
        try{
            List<String> lines_raw = csv_str.split('\n');
            List<List<String>> lines = new List<List<String>>();
            
            //remove first row
            lines_raw.remove(2);
            lines_raw.remove(1);
            lines_raw.remove(0);
            
            //Handling fields with commas
            for(String line : lines_raw) {
                List<String> line_sep = handlerCommaWithinColumn(line);
                
                List<String> fields = new List<String>();
                Boolean makeCompositeField = false;
                String compositeField;
                for(String field : line_sep) {
                    if (field.startsWith('"') && field.endsWith('"')) {
                        fields.add(field.trim());
                    } else if (field.startsWith('"')) {
                        makeCompositeField = true;
                        compositeField = field;
                    } else if (field.endsWith('"')) {
                        compositeField += ',' + field;
                        fields.add(compositeField.trim());
                        makeCompositeField = false;
                    } else if (makeCompositeField) {
                        compositeField +=  ',' + field;
                    } else {
                        fields.add(field.trim());
                    }
                }
                lines.add(fields);
            }
            
            csvWrapper wrap = New csvWrapper();
            List<List<String>> conList = New List<List<String>>();
            List<List<String>> existingConList = New List<List<String>>();
            List<List<String>> attList = New List<List<String>>();
            List<List<String>> emptyList = New List<List<String>>();
            List<String> ardcList = New List<String>();
            List<String> ConArdcList = New List<String>();
            for(List<String> line : lines){
                if(String.isNotBlank(line[4])){
                    Boolean isInteger = line[4].trim().isNumeric();
                    String ARDCWithoutZero = line[4].trim().replaceFirst('^0+', '');
                    if(!ardcList.contains(ARDCWithoutZero) && isInteger == true)
                        ardcList.add(ARDCWithoutZero);
                }
            }
            
            for(Contact con : [SELECT Id,ARDC_Number__c FROM Contact WHERE ARDC_Number__c IN: ardcList]){
                if(!ConArdcList.contains(con.ARDC_Number__c))
                    ConArdcList.add(con.ARDC_Number__c);
            }
            
            String emailPattern = '^[a-zA-Z0-9][a-zA-Z0-9._%+-]*[a-zA-Z0-9]@[a-zA-Z0-9-]+(\\.[a-zA-Z0-9-]+)*\\.[a-zA-Z]{2,6}$';
            for(List<String> line : lines){
                Boolean isInteger = line[4].trim().isNumeric();
                String ARDCWithoutZero = line[4].trim().replaceFirst('^0+', '');
                line[4] = ARDCWithoutZero;
                if(!String.isNotBlank(line[4]) && !String.isNotBlank(line[1])){
                    line.add('Last Name and ARDC# are missing.');
                    emptyList.add(line);
                }
                else if(!String.isNotBlank(line[4])){
                    line.add('ARDC# is missing.');
                    emptyList.add(line);
                }
                else if(!String.isNotBlank(line[6])){
                     line.add('Last Name is missing.');
                    emptyList.add(line);
                }
                else if(String.isNotBlank(line[13]) && !Pattern.matches(emailPattern, line[13])){
                    line.add('Email address is invalid.');
                    emptyList.add(line);
                }
                else if(isInteger == false){
                    line.add('Invalid ARDC#.');
                    emptyList.add(line);
                }
                else{
                    attList.add(line);
                }
                if(String.isNotBlank(line[4]) && String.isNotBlank(line[6]) && !ConArdcList.contains(line[4]) && isInteger == true && !(String.isNotBlank(line[13]) && !Pattern.matches(emailPattern, line[13]))){
                    conList.add(line);
                }
                if(String.isNotBlank(line[4]) && ConArdcList.contains(line[4]) && isInteger == true){
                    existingConList.add(line);
                }
            } 
            wrap.contactList = conList;
            wrap.existingContactList = existingConList;
            wrap.attendeeList = attList;
            wrap.emptyARDCList = emptyList;
            
            return wrap;
        }catch (Exception ex){
            System.debug('Error-->> '+ex.getLineNumber() + '---'+ ex.getMessage());
            AuraHandledException AuraError = new AuraHandledException( ex.getMessage());
            AuraError.setMessage( ex.getMessage());
            throw AuraError;
        }
    }
    
    @AuraEnabled
    public static List<ErrorWrapper> createRecord(csvWrapper wrapper, String eventId){
        List<ErrorWrapper> ErrorWrapperList = new List<ErrorWrapper>();
        CLE_Event__c eve = [SELECT Id, Name FROM CLE_Event__c Where Id=: eventId limit 1];
        List<CLE_Attendance__c> attendeeListToInsert = New List<CLE_Attendance__c>();
        /*List<Contact> contactToInsert = New List<Contact>();
        
        for(List<String> line : wrapper.contactList){
            Contact objCon = New Contact();
            if(String.isNotBlank(line[0]))
                objCon.FirstName = line[0].trim();
            if(String.isNotBlank(line[1]))
                objCon.LastName = line[1].trim();
            if(String.isNotBlank(line[2]))
                objCon.ARDC_Number__c = line[2];
            if(String.isNotBlank(line[11]))
                objCon.ISBA__c = line[11].trim();
            if(String.isNotBlank(line[8]))
                objCon.Email = line[8].trim();
            if(String.isNotBlank(line[15]))
                objCon.Phone = line[15].trim();
            
            objCon.Data_Source__c = eve.Name;
            contactToInsert.add(objCon);
        }
        
        if(!contactToInsert.isEmpty()){
            Database.SaveResult[] contactInsertLists = Database.insert(contactToInsert);
        } */
        
        // create lead instead of contact
        List<Lead> leadToInsert = New List<Lead>();
        
        for(List<String> line : wrapper.contactList){
            Lead objLead = New Lead();
            if(String.isNotBlank(line[5]))
                objLead.FirstName = line[5].trim();
            if(String.isNotBlank(line[6]))
                objLead.LastName = line[6].trim();
            if(String.isNotBlank(line[4]))
                objLead.ARDC_Number__c = line[4];
            // if(line.size() >= 12 && String.isNotBlank(line[11]))
            //     objLead.ISBA_Member_Number__c = line[11].trim();
            if(String.isNotBlank(line[13]))
                objLead.Email = line[13].trim();
            if(line.size() >= 16 &&String.isNotBlank(line[15]))
                objLead.Phone = line[15].trim();
            
            objLead.Company = 'unknown';
            objLead.Data_Source__c = eve.Name;
            leadToInsert.add(objLead);
        }
        
        Database.SaveResult[] leadInsertLists = new List<Database.SaveResult>();
        if(!leadToInsert.isEmpty()){
            leadInsertLists = Database.insert(leadToInsert, false);
            for(integer i = 0; i < leadToInsert.size(); i++){
                if(!leadInsertLists[i].isSuccess()){
                    String error;
                    for(Database.Error err : leadInsertLists[i].getErrors()) {
                        if(String.isNotBlank(error)){
                            error += ' \n'+err.getMessage();
                        }
                        else{
                            error = err.getMessage();
                        }                    
                        System.debug(err.getStatusCode() + ': ' + err.getMessage());
                    }
                    ErrorWrapper ew = new ErrorWrapper();
                    ew.record = leadToInsert[i];
                    ew.error = error;
                    ErrorWrapperList.add(ew);
                }
            }
        }
        
        List<String> ardcList = New List<String>();
        Map<String,Contact> ConArdcMap = New  Map<String,Contact>();
        Map<String, Lead> leadArdcMap = new Map<String, Lead>();
        
        for(List<String> line : wrapper.attendeeList){
            if(String.isNotBlank(line[4])){
                if(!ardcList.contains(line[4].trim()))
                    ardcList.add(line[4].trim());
            }
        }
        
		
        for(Contact con : [SELECT Id,ARDC_Number__c FROM Contact WHERE ARDC_Number__c IN: ardcList]){
            if(!ConArdcMap.containskey(con.ARDC_Number__c))
                ConArdcMap.put(con.ARDC_Number__c,con);
        }

        for(Lead lead : [SELECT Id,ARDC_Number__c FROM Lead WHERE ARDC_Number__c IN: ardcList]){
            if(!leadArdcMap.containskey(lead.ARDC_Number__c))
                leadArdcMap.put(lead.ARDC_Number__c,lead);
        }
        
        //new Addition by Ramavtar for preventing the duplication of CLE_Attendance__c
		Set<String> contactIds = new Set<String>();
        Set<String> leadIds = new Set<String>();
        for(CLE_Attendance__c at : [SELECT Id, Contact__c,Lead__c FROM CLE_Attendance__c WHERE CLE_Event__c=:eventId]){
            if(String.isNotBlank(at.Contact__c)){
                contactIds.add(at.Contact__c);
            }
            if(String.isNotBlank(at.Lead__c)){
                leadIds.add(at.Lead__c);
            }
        }
        
        for(List<String> line : wrapper.attendeeList){
            if(leadArdcMap.containsKey(line[4]) && !leadIds.contains(leadArdcMap.get(line[4]).Id)){
                CLE_Attendance__c attendee = New CLE_Attendance__c();
                attendee.CLE_Event__c = eventId;
                attendee.Lead__c = leadArdcMap.get(line[4]).Id;
                if(String.isNotBlank(line[3])){
                    attendee.Lawyer_Participation_Method__c = line[3].trim();
                }
                if(String.isNotBlank(line[13]))
                    attendee.Email__c = line[13].trim();
                if(line.size() >= 10 && String.isNotBlank(line[9]))
                    attendee.General_Credit__c = Decimal.valueOf(String.valueOf(line[9]));      
                if(line.size() >= 11 && String.isNotBlank(line[10]))
                    attendee.PR_MHSA__c = Decimal.valueOf(String.valueOf(line[11]));      
                if(line.size() >= 12 && String.isNotBlank(line[11]))
                    attendee.PR_DIV__c = Decimal.valueOf(String.valueOf(line[10]));      
                if(line.size() >= 13 && String.isNotBlank(line[12]))
                    attendee.PR_OTHER__c = Decimal.valueOf(String.valueOf(line[12])); 
                attendeeListToInsert.add(attendee);
            }
        }
        
        for(List<String> line : wrapper.attendeeList){
            if(ConArdcMap.containsKey(line[4]) && !contactIds.contains(ConArdcMap.get(line[4]).Id)){
                CLE_Attendance__c attendee = New CLE_Attendance__c();
                attendee.CLE_Event__c = eventId;
                attendee.Contact__c = ConArdcMap.get(line[4]).Id;
                if(String.isNotBlank(line[3])){
                    attendee.Lawyer_Participation_Method__c = line[3].trim();
                }
                if(String.isNotBlank(line[13]))
                    attendee.Email__c = line[13].trim();
                if(line.size() >= 10 && String.isNotBlank(line[9]))
                    attendee.General_Credit__c = Decimal.valueOf(String.valueOf(line[9]));      
                if(line.size() >= 11 && String.isNotBlank(line[10]))
                    attendee.PR_MHSA__c = Decimal.valueOf(String.valueOf(line[11]));      
                if(line.size() >= 12 && String.isNotBlank(line[11]))
                    attendee.PR_DIV__c = Decimal.valueOf(String.valueOf(line[10]));      
                if(line.size() >= 13 && String.isNotBlank(line[12]))
                    attendee.PR_OTHER__c = Decimal.valueOf(String.valueOf(line[12])); 
                attendeeListToInsert.add(attendee);
            }
        }
        
        if(!attendeeListToInsert.isEmpty()){
            Database.SaveResult[] attendeeInsertLists = Database.insert(attendeeListToInsert, false);
            
            for(Database.SaveResult res: attendeeInsertLists){
                system.debug(res);
            }
        } 
        
        if(!ErrorWrapperList.isEmpty()){
            return ErrorWrapperList;
        }
        return null;
    }
    
    public class csvWrapper{
        @AuraEnabled public List<List<String>> contactList{get;set;}
        @AuraEnabled public List<List<String>> existingContactList{get;set;}
        @AuraEnabled public List<List<String>> attendeeList{get;set;}
        @AuraEnabled public List<List<String>> emptyARDCList{get;set;}
    }
    
    public class ErrorWrapper{
        @AuraEnabled public Lead record{get;set;}
        @AuraEnabled public String error{get;set;}
    }
}