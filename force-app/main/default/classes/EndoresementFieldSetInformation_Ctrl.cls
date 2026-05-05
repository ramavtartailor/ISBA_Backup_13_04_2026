public class EndoresementFieldSetInformation_Ctrl {
    public String endorsementName{get;set;}
    public EndoresementFieldSetInformation_Ctrl(ApexPages.StandardController stdController) {
        endorsementName = 'IL 107 Purchase Extended Reporting Endorsement';
    }
    public List<SelectOption> getLayouts() {
        List<SelectOption> options = new List<SelectOption>();
        options.add(new SelectOption('IL 107 Purchase Extended Reporting Endorsement' ,'IL 107 Purchase Extended Reporting Endorsement'));
        options.add(new SelectOption('IL 107B U.S. Active Duty Military Service Extended Reporting Period Election','IL 107B U.S. Active Duty Military Service Extended Reporting Period Election'));
        options.add(new SelectOption('IL 107C Unlimited Death or Disability Extended Reporting Period Election','IL 107C Unlimited Death or Disability Extended Reporting Period Election'));
        options.add(new SelectOption('IL 107D Unlimited Retirement Extended Reporting Period Election Endorsement','IL 107D Unlimited Retirement Extended Reporting Period Election Endorsement'));
        options.add(new SelectOption('IL 120 Limit of Liability Endorsement','IL 120 Limit of Liability Endorsement'));
        options.add(new SelectOption('IL 151 Name Change Endorsement','IL 151 Name Change Endorsement'));
        options.add(new SelectOption('IL 151A Address Change Endorsement','IL 151A Address Change Endorsement'));
        options.add(new SelectOption('IL 190 Cancellation of Coverage','IL 190 Cancellation of Coverage'));
        options.add(new SelectOption('IL 191 Reinstatement Notice','IL 191 Reinstatement Notice'));
        options.add(new SelectOption('IL 101A SPECIFIC ATTORNEY(S) EXCLUSION ENDORSEMENT','IL 101A SPECIFIC ATTORNEY(S) EXCLUSION ENDORSEMENT'));
        options.add(new SelectOption('IL 101B SPECIFIC ATTORNEY(S) EXCLUSION ENDORSEMENT','IL 101B SPECIFIC ATTORNEY(S) EXCLUSION ENDORSEMENT'));
        options.add(new SelectOption('IL 104 SPECIFIC ENTITY EXCLUSIONS ENDORSEMENT','IL 104 SPECIFIC ENTITY EXCLUSIONS ENDORSEMENT'));
        options.add(new SelectOption('IL 106 AMENDMENT OF EXTENDED REPORTING PERIOD','IL 106 AMENDMENT OF EXTENDED REPORTING PERIOD'));
        options.add(new SelectOption('IL 110 SECURITIES, BOND AND LIMITED PARTNERSHIP EXCLUSION','IL 110 SECURITIES, BOND AND LIMITED PARTNERSHIP EXCLUSION'));
        options.add(new SelectOption('IL 130 LIMIT OF LIABILITY ENDORSEMENT','IL 130 LIMIT OF LIABILITY ENDORSEMENT'));
        options.add(new SelectOption('IL 150 POLICY ENDORSEMENT','IL 150 POLICY ENDORSEMENT'));
        options.add(new SelectOption('IL 160 CONTRACTUAL LIABILITY EXCLUSION ENDORSEMENT','IL 160 CONTRACTUAL LIABILITY EXCLUSION ENDORSEMENT'));
        options.add(new SelectOption('IL 162 FDCPA ENDORSEMENT','IL 162 FDCPA ENDORSEMENT'));
        options.add(new SelectOption('IL 169 SECURITIES EXCLUSION ENDORSEMENT','IL 169 SECURITIES EXCLUSION ENDORSEMENT'));
        options.add(new SelectOption('IL 174A CLAIM AND DISCIPLINARY PROCEEDINGS EXCLUSION ENDORSEMENT','IL 174A CLAIM AND DISCIPLINARY PROCEEDINGS EXCLUSION ENDORSEMENT'));
        options.add(new SelectOption('IL 175 PREDECESSOR FIRM ENDORSEMENT','IL 175 PREDECESSOR FIRM ENDORSEMENT'));
        options.add(new SelectOption('IL 176A ENTITY ENDORSEMENT','IL 176A ENTITY ENDORSEMENT'));
        options.add(new SelectOption('IL 177 DISCIPLINARY PROCEEDINGS COVERAGE ENDORSEMENT','IL 177 DISCIPLINARY PROCEEDINGS COVERAGE ENDORSEMENT'));
        options.add(new SelectOption('IL 200 PAST ACTS COVERAGE BUYBACK ENDORSEMENT','IL 200 PAST ACTS COVERAGE BUYBACK ENDORSEMENT'));
        options.add(new SelectOption('IL 210 SEPARATELY OWNED TITLE AGENCY','IL 210 SEPARATELY OWNED TITLE AGENCY'));
        options.add(new SelectOption('IL 230 ANNUAL AGGREGATE DEDUCTIBLE ENDORSEMENT','IL 230 ANNUAL AGGREGATE DEDUCTIBLE ENDORSEMENT'));
        options.add(new SelectOption('IL 232 ANNUAL AGGREGATE DEDUCTIBLE','IL 232 ANNUAL AGGREGATE DEDUCTIBLE'));
        options.add(new SelectOption('IL 234 LOSS ONLY DEDUCTIBLE ENDORSEMENT','IL 234 LOSS ONLY DEDUCTIBLE ENDORSEMENT'));
        options.add(new SelectOption('IL 260 Past Acts Coverage Endorsement','IL 260 Past Acts Coverage Endorsement'));
        options.add(new SelectOption('IL 301 Amendment of EXTENDED REPORTING PERIOD Options Endorsement','IL 301 Amendment of EXTENDED REPORTING PERIOD Options Endorsement'));
        options.add(new SelectOption('IL 261 Claim Expenses Outside the Policy Limits Endorsement','IL 261 Claim Expenses Outside the Policy Limits Endorsement'));
        return options;
    } 
    public List<Schema.FieldSetMember> getFields() {
        if(endorsementName.equalsIgnoreCase('IL 107 Purchase Extended Reporting Endorsement')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_107.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 107B U.S. Active Duty Military Service Extended Reporting Period Election')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_107B.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 107C Unlimited Death or Disability Extended Reporting Period Election')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_107C.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 107D Unlimited Retirement Extended Reporting Period Election Endorsement')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_107D.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 120 Limit of Liability Endorsement')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_120.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 151 Name Change Endorsement')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_151.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 151A Address Change Endorsement')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_151A.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 190 Cancellation of Coverage')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_190.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 191 Reinstatement Notice')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_191.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 101A SPECIFIC ATTORNEY(S) EXCLUSION ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_101A.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 101B SPECIFIC ATTORNEY(S) EXCLUSION ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_101B.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 104 SPECIFIC ENTITY EXCLUSIONS ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_104.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 106 AMENDMENT OF EXTENDED REPORTING PERIOD')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_106.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 110 SECURITIES, BOND AND LIMITED PARTNERSHIP EXCLUSION')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_110.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 130 LIMIT OF LIABILITY ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_130.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 150 POLICY ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_150.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 160 CONTRACTUAL LIABILITY EXCLUSION ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_160.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 162 FDCPA ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_162.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 169 SECURITIES EXCLUSION ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_169.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 174A CLAIM AND DISCIPLINARY PROCEEDINGS EXCLUSION ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_174A.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 175 PREDECESSOR FIRM ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_175.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 176A ENTITY ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_176A.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 177 DISCIPLINARY PROCEEDINGS COVERAGE ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_177.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 200 PAST ACTS COVERAGE BUYBACK ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_200.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 210 SEPARATELY OWNED TITLE AGENCY')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_210.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 230 ANNUAL AGGREGATE DEDUCTIBLE ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_230.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 232 ANNUAL AGGREGATE DEDUCTIBLE')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_232.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 234 LOSS ONLY DEDUCTIBLE ENDORSEMENT')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_234.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 260 Past Acts Coverage Endorsement')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_260.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 301 Amendment of EXTENDED REPORTING PERIOD Options Endorsement')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_301.getFields();
        }else if(endorsementName.equalsIgnoreCase('IL 261 Claim Expenses Outside the Policy Limits Endorsement')){
            return SObjectType.Policy_Endorsement__c.FieldSets.IL_261.getFields();
        }
        return new List<Schema.FieldSetMember>();
    }
}