public class CreateEndorsementsEXT {
    private String SObjectPrefix = null;
    
    public CreateEndorsementsEXT(ApexPages.StandardController controller){
        this.SObjectPrefix = controller.getRecord().getSObjectType().getDescribe().getKeyPrefix();
    }
    
    public PageReference onLoadPage(){
		system.debug(JSON.serializePretty(ApexPages.currentPage().getParameters()));
		String retURL = ApexPages.currentPage().getParameters().get('retURL');
		
		if(ApexPages.currentPage().getParameters().get('save_new')=='1' && retURL != null && retURL.startsWith('/'+SObjectPrefix) && retURL.indexOf('/', 4) < 0 && !retURL.contains('?') && retURL.length() >= 15) {
			PageReference pg = new PAgeReference(retURL); pg.setRedirect(true); return pg;
		} else {
			PageReference pg = new PAgeReference('/'+this.SObjectPrefix+'/e');
            for(String key : ApexPages.currentPage().getParameters().keyset()){
                if(key == 'save_new' || key == 'sfdc.override') {continue;} pg.getParameters().put(key, ApexPages.currentPage().getParameters().get(key));
            }
               
			pg.getParameters().put('nooverride','1');
			pg.setRedirect(true);
			return pg;
		}
    }
}