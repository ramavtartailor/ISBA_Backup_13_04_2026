public class ForteTransactionWrapper{
	public String transaction_id;	//trn_939ca9d9-deed-4cef-8902-f10f5a509e6c
	public String organization_id;	//org_302974
	public String location_id;	//loc_171818
	public String order_number;	//114761560
	public String reference_id;	//114761560
	public String funding_id;	//fnd_ACH-1221-46FC9
	public String status;	//funded
	public String action;	//sale
	public Decimal authorization_amount;	//525
	public String authorization_code;	//23573753
	public String entered_by;	//9bfdab47c4d0ad57fa7d
	public String received_date;	//2021-12-15T03:00:22.423
	public String origination_date;	//2021-12-15T17:32:47.063
	public cls_billing_address billing_address;
	public cls_echeck echeck;
	public cls_settlements[] settlements;
	public cls_xdata xdata;
	public String biller_name;	//Marks, Susan
	public Integer attempt_number;	//1
	public cls_response response;
	public cls_links links;
	class cls_billing_address {
		public String first_name;	//Susan
		public String last_name;	//Marks
		public String company_name;	//SAM LAW OFFICE, LLC
	}
	class cls_echeck {
		public String masked_account_number;	//****6271
		public String last_4_account_number;	//6271
		public String routing_number;	//071000013
		public String account_type;	//checking
		public String sec_code;	//WEB
	}
	class cls_settlements {
		public String settle_id;	//stl_d3151821-b29f-4d18-a1f1-f6d61f1d31f1
		public String organization_id;	//org_302974
		public String location_id;	//loc_171818
		public String transaction_id;	//trn_939ca9d9-deed-4cef-8902-f10f5a509e6c
		public String order_number;	//114761560
		public String reference_id;	//114761560
		public String funding_id;	//fnd_ACH-1221-46FC9
		public String settle_batch_id;	//
		public String settle_date;	//2021-12-21T00:00:00
		public String settle_type;	//deposit
		public String settle_response_code;	//S01
		public Decimal settle_amount;	//525
		public String method;	//echeck
		public cls_links links;
	}
	class cls_links {
		public String disputes;	//https://api.forte.net/v3/transactions/trn_939ca9d9-deed-4cef-8902-f10f5a509e6c/disputes
		public String settlements;	//https://api.forte.net/v3/transactions/trn_939ca9d9-deed-4cef-8902-f10f5a509e6c/settlements
		public String self;	//https://api.forte.net/v3/transactions/trn_939ca9d9-deed-4cef-8902-f10f5a509e6c/
	}
	class cls_xdata {
		public String xdata_1;	//114761560
		public String xdata_2;	//119903
		public String xdata_3;	//SAM LAW OFFICE, LLC
	}
	class cls_response {
		public String environment;	//live
		public String response_type;	//A
		public String response_code;	//A01
		public String response_desc;	//APPROVED
		public String authorization_code;	//23573753
		public String preauth_result;	//POS
		public String preauth_desc;	//P70:VALIDATED
	}
	public static ForteTransactionWrapper parse(String json){
		return (ForteTransactionWrapper) System.JSON.deserialize(json, ForteTransactionWrapper.class);
	}
    
	/*public static testMethod void testParse() {
		String json=		'{'+
		'    "transaction_id": "trn_939ca9d9-deed-4cef-8902-f10f5a509e6c",'+
		'    "organization_id": "org_302974",'+
		'    "location_id": "loc_171818",'+
		'    "order_number": "114761560",'+
		'    "reference_id": "114761560",'+
		'    "funding_id": "fnd_ACH-1221-46FC9",'+
		'    "status": "funded",'+
		'    "action": "sale",'+
		'    "authorization_amount": 525.00,'+
		'    "authorization_code": "23573753",'+
		'    "entered_by": "9bfdab47c4d0ad57fa7d",'+
		'    "received_date": "2021-12-15T03:00:22.423",'+
		'    "origination_date": "2021-12-15T17:32:47.063",'+
		'    "billing_address": {'+
		'        "first_name": "Susan",'+
		'        "last_name": "Marks",'+
		'        "company_name": "SAM LAW OFFICE, LLC"'+
		'    },'+
		'    "echeck": {'+
		'        "masked_account_number": "****6271",'+
		'        "last_4_account_number": "6271",'+
		'        "routing_number": "071000013",'+
		'        "account_type": "checking",'+
		'        "sec_code": "WEB"'+
		'    },'+
		'    "settlements": ['+
		'        {'+
		'            "settle_id": "stl_d3151821-b29f-4d18-a1f1-f6d61f1d31f1",'+
		'            "organization_id": "org_302974",'+
		'            "location_id": "loc_171818",'+
		'            "transaction_id": "trn_939ca9d9-deed-4cef-8902-f10f5a509e6c",'+
		'            "order_number": "114761560",'+
		'            "reference_id": "114761560",'+
		'            "funding_id": "fnd_ACH-1221-46FC9",'+
		'            "settle_batch_id": "",'+
		'            "settle_date": "2021-12-21T00:00:00",'+
		'            "settle_type": "deposit",'+
		'            "settle_response_code": "S01",'+
		'            "settle_amount": 525.00,'+
		'            "method": "echeck",'+
		'            "links": {'+
		'                "self": "https://api.forte.net/v3/settlements/stl_d3151821-b29f-4d18-a1f1-f6d61f1d31f1"'+
		'            }'+
		'        }'+
		'    ],'+
		'    "xdata": {'+
		'        "xdata_1": "114761560",'+
		'        "xdata_2": "119903",'+
		'        "xdata_3": "SAM LAW OFFICE, LLC"'+
		'    },'+
		'    "biller_name": "Marks, Susan",'+
		'    "attempt_number": 1,'+
		'    "response": {'+
		'        "environment": "live",'+
		'        "response_type": "A",'+
		'        "response_code": "A01",'+
		'        "response_desc": "APPROVED",'+
		'        "authorization_code": "23573753",'+
		'        "preauth_result": "POS",'+
		'        "preauth_desc": "P70:VALIDATED"'+
		'    },'+
		'    "links": {'+
		'        "disputes": "https://api.forte.net/v3/transactions/trn_939ca9d9-deed-4cef-8902-f10f5a509e6c/disputes",'+
		'        "settlements": "https://api.forte.net/v3/transactions/trn_939ca9d9-deed-4cef-8902-f10f5a509e6c/settlements",'+
		'        "self": "https://api.forte.net/v3/transactions/trn_939ca9d9-deed-4cef-8902-f10f5a509e6c/"'+
		'    }'+
		'}';
		ForteTransactionWrapper obj = parse(json);
		System.assert(obj != null);
	}*/
}