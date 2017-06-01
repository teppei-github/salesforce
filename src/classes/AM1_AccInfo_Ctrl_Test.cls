@isTest
private class AM1_AccInfo_Ctrl_Test{

    static testMethod void myUnitTest1() {
        // 新規取引先
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;
                
        //新規取引先責任者
        List<Contact> testContList = new List<Contact>();
        for(Integer i=0; i<2;i++){
            Contact testCont = new Contact(Email = 'test@test.co.jp',
                                   FirstName = 'Test',
                                   LastName = 'Contact',                                  
                                   NCCCNameKanji__c = 'テスト太郎',
                                   NJCCustomerPortalUser__c = true,
                                   Department = '開発部',
                                   Title = '新入社員',
                                   Description = '説明です。。。。。。。',
                                   AccountId =  testAcc.id);
            testContList.add(testCont);
        }   
        insert testContList;      

        // URLパラメータにidを渡す
        apexpages.currentpage().getparameters().put('id' , testAcc.id);
        
        ApexPages.StandardController std = new ApexPages.StandardController(testAcc);
        AM1_AccInfo_Ctrl testAccount = new AM1_AccInfo_Ctrl(std);
        testAccount.Feedid = null;
        
        
        // 取引先のチェック
        System.assertEquals(testAccount.acc.Name,'Test Account');
        
        // 取引先責任者チェック
        System.assertEquals(testAccount.accCont[0].Title,'新入社員');
        System.assertEquals(testAccount.accCont[1].Department,'開発部');
    }
}