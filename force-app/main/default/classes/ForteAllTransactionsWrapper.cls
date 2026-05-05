public class ForteAllTransactionsWrapper{
	public Integer number_results;	//7164
	public cls_search_criteria search_criteria;
	public cls_results[] results;
	public cls_response response;
	public cls_links links;
	class cls_search_criteria {
		public Integer page_size;	//50
		public Integer page_index;	//0
		public String home_organization_id;	//org_302974
		public cls_resource_specific resource_specific;
	}
	class cls_resource_specific {
		public String location_id;	//loc_171818
		public String start_received_date;	//2022-10-20T09:39:32.7503171-07:00
		public String end_received_date;	//2023-01-18T09:39:32.7503171-08:00
	}
	public class cls_results {
		public String transaction_id;	//trn_30e053a2-b2fc-4bae-a451-08098344db4b
		public String organization_id;	//org_302974
		public String location_id;	//loc_171818
		public String order_number;	//114767122-
		public String reference_id;	//114767122
		public String status;	//settled
		public String action;	//sale
		public Double authorization_amount;	//192.83
		public String authorization_code;	//776505
		public String entered_by;	//9bfdab47c4d0ad57fa7d
		public String received_date;	//2022-10-20T13:58:00.393
		public cls_billing_address billing_address;
		public cls_card card;
		public cls_response response;
		public cls_links links;
        public String origination_date;
        public String customer_id;
        public Double service_fee_amount;
	}
	public class cls_billing_address {
		public String first_name;	//Joyce
		public String last_name;	//Stevens
		public String company_name;	//Law Office of Joyce
	}
	class cls_card {
		public String name_on_card;	//Joyce L. Stevens
		public String last_4_account_number;	//9441
		public String masked_account_number;	//****9441
		public Integer expire_month;	//10
		public Integer expire_year;	//2026
		public String card_type;	//visa
	}
	public class cls_response {
		public String environment;	//live
		public String response_desc;	//Get Successful.
        public String response_code ;
	}
	public class cls_links {
		public String self;	//https://api.forte.net/v3/transactions/
		public String next;	//https://api.forte.net/v3/transactions/?page_index=1
	}
	public static ForteAllTransactionsWrapper parse(String json){
		return (ForteAllTransactionsWrapper) System.JSON.deserialize(json, ForteAllTransactionsWrapper.class);
	}
}