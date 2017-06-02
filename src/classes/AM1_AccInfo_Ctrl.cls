public with sharing class AM1_AccInfo_Ctrl {
    
    public Account acc {get;set;}
    public List<Contact> accCont {get;set;}
    public string baseUrl {get; set;}
    public string userId {get; set;}
    public string feedId {get; set;}
    public string industyDisp1 {get; set;}
    public string industyDisp2 {get; set;}
    public string industyDisp3 {get; set;}

    // コンストラクタ
    public AM1_AccInfo_Ctrl (ApexPages.StandardController controller) {
    
        // IDからオブジェクト名を取得する
        String strId = Apexpages.currentPage().getParameters().get('id');

        // 利用者のIDを取得する
        userId = userinfo.getuserid();

        // BaseURL取得
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        // 取引先情報
        List<Account> lstAcc = [Select Id
                                      ,Name
                                      ,PICSTFPU__c
                                      ,PICSTFID__r.Name
                                      ,lbc_industry_name1__c
                                      ,lbc_industry_name2__c
                                      ,lbc_industry_name3__c
                                      ,CSTCD__c
                                      ,ShippingPostalCode
                                      ,ShippingState
                                      ,ShippingCity
                                      ,ShippingStreet
                                      ,Phone
                                      ,CustomerType__c
                                      ,Description
                                      ,lbc_representative_title__c
                                      ,lbc_representative__c
                                      ,lbc_url__c
                                  from Account
                                 where id = :strId ];
        if(lstAcc.size() > 0) acc = lstAcc[0];

        // 業種の選択ボタン作成        
        if(acc.lbc_industry_name1__c == null) industyDisp1 = 'display:none';
        if(acc.lbc_industry_name2__c == null) industyDisp2 = 'display:none';
        if(acc.lbc_industry_name3__c == null) industyDisp3 = 'display:none';

        // 取引先責任者情報
        List<Contact> lstAccCont = [Select Id
                                          ,AccountId
                                          ,Name
                                          ,NJCCustomerPortalUser__c
                                          ,Department
                                          ,Title
                                          ,Description
                                      from Contact
                                     where AccountId = :strId ];
                                     
        accCont = new List<Contact>();
        
        for(Integer i=0;i<lstAccCont.Size();i++){
            accCont.add(lstAccCont[i]);
        }
        
        List<AccountFeed> fd = [select id from AccountFeed where parentid = : acc.id limit 1];
        if(fd.size() > 0) feedId = fd [0].id;
        
        
    }
    
}