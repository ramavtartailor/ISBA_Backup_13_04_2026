public class ReportPdfConverter {
    Public Map<Integer, List<DataRow>> RowNumberToDataMap {get;set;}
    Public List<String> ColumnName {get;set;}
    Public List<String> aggregateValuesList {get;set;}
    Public Account accRec {get;set;}
    Public String dateRange {get;set;}
    public ReportPdfConverter(){
        ColumnName = new List<String>();
        aggregateValuesList = new List<String>();
        RowNumberToDataMap = new Map<Integer, List<DataRow>>();
        accRec = new Account();
        dateRange = '-';
        // Get the report ID
        List <Report> reportList = [SELECT Id,DeveloperName FROM Report where 
                                    Id =: Label.Claim_Loss_Run_report  ];
        String reportId = (String)reportList.get(0).get('Id');
        // Get the report metadata
        Reports.ReportDescribeResult describe = Reports.ReportManager.describeReport(reportId);
        Reports.ReportMetadata reportMd = describe.getReportMetadata();
        
        //ColumnName = reportMd.getDetailColumns();
        // Override filter and run report
        List<Reports.ReportFilter> filterList = reportMd.getReportFilters();
        //system.assert(false,filterList);
        Reports.reportResults results;
        
        if(filterList.size() > 0){
            filterList[0].setValue(Apexpages.currentPage().getParameters().get('fv0'));
            filterList[1].setValue(Apexpages.currentPage().getParameters().get('fv1'));
            results = Reports.ReportManager.runReport(reportId, reportMd,true);
            if(!String.isBlank(Apexpages.currentPage().getParameters().get('fv0'))){
                accRec = [Select Id, Name, AccountNumber from Account where Id =: Apexpages.currentPage().getParameters().get('fv0')];
            } if(!String.isBlank(Apexpages.currentPage().getParameters().get('fv1'))){
                dateRange = Apexpages.currentPage().getParameters().get('fv1');
                if(dateRange == 'LAST 100 YEARS'){
                    dateRange = 'Full Historical Data';
                }
            }
        } else{
            results = Reports.ReportManager.runReport(reportId,true);
        }
        //Reports.reportResults results = Reports.ReportManager.runReport(reportId, reportMd,true);
        
        Reports.ReportExtendedMetadata rmd =   results.getReportExtendedMetadata();
        
        // Get detail columns from extended metadata
        Map<String,Reports.DetailColumn> colMap = rmd.getDetailColumnInfo();
        
        for(String key : colMap.KeySet()){
            System.debug('Key=' + Key + ' label=' + colMap.get(key).getLabel());
            ColumnName.add(colMap.get(key).getLabel());
        }  
        
        Reports.ReportFactWithDetails factDetails =
            (Reports.ReportFactWithDetails)results.getFactMap().get('T!T');
         List<Reports.SummaryValue> sumVal = factDetails.getAggregates();
        
        for(Reports.SummaryValue reportSummVal  : factDetails.getAggregates()){
            aggregateValuesList.add(reportSummVal.getLabel());
        }
       	 System.debug('Summary Value: ' + sumVal);
        System.debug('size'+factDetails.getRows().size());
        // system.assert(false,factDetails.getRows().size());
        for(integer count = 0 ; count < factDetails.getRows().size(); count ++ ){
            Reports.ReportDetailRow detailRow = factDetails.getRows()[count];
            List<DataRow> dataRows = new List<DataRow>();
            for(Reports.ReportDataCell rw : detailRow.getDataCells()){
                dataRows.add( new DataRow((String)rw.getLabel()));
            }
            if(dataRows.size() > 0)
                RowNumberToDataMap.put(count,dataRows);
        }
    }
    
    Public Class DataRow{
        
        Public String Label{get;Set;}
        Public String Value{get;Set;}
        
        public DataRow( String label){
            this.Label = label;
            // this.Value = value;
        }
    }
}