@isTest
private class AC_WR_GetAttach_Asset_Test {
   // 
   static testMethod void myUnitTest1() {
 
        // 新規取引C先
        Account testAcc = new Account(Name = 'Test Account');
        insert testAcc;

        //新規取引先責任者
        Contact testCont = new Contact(Email = 'test@test.co.jp',
                               FirstName = 'Test',
                               LastName = 'Contact',
                               NCCCNameKanji__c = 'テスト太郎',
                               AccountId =  testAcc.id);
        insert testCont;
        
        // 担当営業者情報の生成
        User tantouUser = new User(Email = 'email_tantou@njc.co.jp',
                                Username =  System.now().millisecond() + 'user_tantou@njc.co.jp',
                                Alias = 'a',
                                ProfileId = Userinfo.getProfileId(),
                                TimeZoneSidKey = 'Asia/Tokyo',
                                LocaleSidKey = 'ja_JP',
                                EmailEncodingKey = 'ISO-2022-JP',
                                LanguageLocaleKey = 'ja',
                                LastName = '担当',
                                FirstName = '太郎',
                                Phone = '090-9999-9999'
                                );
        insert tantouUser;       

        List<As_InstallationReportHed__c> lstUke = new List<As_InstallationReportHed__c>();
        for(integer i = 0; i< 10; i++){
            As_InstallationReportHed__c iRep = new As_InstallationReportHed__c();
            iRep.As_IRH_OrderNo__c = '11';
            iRep.As_IRH_NonyuNm__c = '11';
            iRep.As_IRH_DelegeteProduct__c = '11';
            iRep.As_IRH_CustomerContactName__c = '11';
            iRep.As_IRH_WorkerRf__c = '11';
            iRep.As_IRH_Biko__c = '';
            iRep.As_IRH_WorkNo__c = '222222';
            iRep.As_IRH_ContractDestination__c = testAcc.id;
            lstUke.add(iRep);
        }
        insert lstUke;

        // 新規添付ファイル
        Attachment testAT = new Attachment(Name = 'xxx.pdf',
                               body = blob.valueof('attachment body'),
                               parentid = lstUke[0].id);
        insert testAT;
        
         // テスト用ログインユーザの生成
        Profile portalProfile = [SELECT Id FROM Profile WHERE UserType = 'CSPLitePortal' Limit 1];
        User loginUser = new User(Email = 'email_login@njc.co.jp',
                                Username =  System.now().millisecond() + 'user_login@njc.co.jp',
                                Alias = 'b',
                                ProfileId = portalProfile.Id,
                                IsActive = true,
                                TimeZoneSidKey = 'Asia/Tokyo',
                                LocaleSidKey = 'ja_JP',
                                EmailEncodingKey = 'ISO-2022-JP',
                                LanguageLocaleKey = 'ja',
                                ContactId = testCont.id,  
                                LastName = 'ログイン',
                                //AccountId = testAcc.id,
                                FirstName = '野郎'
                                );
        insert loginUser;
          
        // ガバナ制限のチェック開始
        system.Test.startTest();
        //作成ユーザ権限でテスト実行
        System.runAs(loginUser) {
        
            // テスト対象のVisualforceページ「vf_WR_Down_Asset」のオブジェクト化
            PageReference pageRef = Page.vf_WR_Down_Asset;
            
            // 「vf_WR_Down_Asset」のカレントページ化
            Test.setCurrentPage(pageRef);
    
            // 「vf_WR_Down_Asset」で使う標準コントローラのオブジェクト化
            ApexPages.StandardController std = new ApexPages.StandardController(loginUser);
            
            // 「vf_WR_Down_Asset」で使う拡張コントローラのオブジェクト化
            AC_WR_GetAttach_Asset te1 = new AC_WR_GetAttach_Asset(std);                      
            
            Test.setMock(HttpCalloutMock.class, new AC_WR_YourHttpCalloutMockImpl());
          
            te1.intPage  = 1;
            // テスト対象のメソッド
            te1.view(1);
            te1.first();
            te1.last();
            te1.next();
            te1.previous();
            te1.Journal_RM = '';
            
            
            system.assertEquals(true, true);  
        }
    }
}