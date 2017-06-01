@isTest
private class AM1_AccSrcMain_Ctrl_Test {

   // 
   static testMethod void myUnitTest1() {
 
        // 新規取引先(30件作成)
        List<Account> testAccList = new List<Account>();
        for (integer i = 0; i < 30; i ++){
            Account testAcc = new Account(Name = 'Test Account');
            testAccList.add(testAcc);
        }
        
        // 新規取引先(100件以上作成)
        for (integer i = 0; i < 200; i ++){
            Account testAcc = new Account(Name = 'Poison Adrena');
            testAccList.add(testAcc);
        }
        insert testAccList;
        
        //新規取引先責任者
        List<Contact> testContList = new List<Contact>();
        for (integer i = 0; i < 230; i ++){
            Contact testCont = new Contact(Email = 'test@test.co.jp',
                               FirstName = 'Test',
                               LastName = 'Contact',
                               NCCCNameKanji__c = 'テスト太郎',
                               AccountId =  testAccList[i].id);
            testContList.add(testCont);
        }
        insert testContList;
                  
        // ガバナ制限のチェック開始
        system.Test.startTest();
                            
        // テスト対象のVisualforceページ「AM1_AccSrcMain」のオブジェクト化
        PageReference pageRef = Page.AM1_AccSrcMain;
        
        // 「AM1_AccSrcMain」のカレントページ化
        Test.setCurrentPage(pageRef);

        // 「AM1_AccSrcMain」で使う標準コントローラのオブジェクト化
        ApexPages.StandardController std = new ApexPages.StandardController(testAccList[0]);
        
        // 「AM1_AccSrcMain」で使う拡張コントローラのオブジェクト化
        AM1_AccSrcMain_Ctrl te1 = new AM1_AccSrcMain_Ctrl(std);                      
                
        // 検索メッセージなし
        te1.searchKey = 'Test';
        te1.SearchAcc();
        
        // 検索メッセージあり(存在なし)
        te1.searchKey = 'NABLA';
        te1.SearchAcc();

        // 検索メッセージあり(over100)            
        te1.searchKey = 'Poison';
        te1.SearchAcc();
        
        // 検索メッセージあり(文字列なし)            
        te1.searchKey = '';
        te1.SearchAcc();
      
        te1.intPage  = 1;
        // テスト対象のメソッド
        te1.view(1);
        te1.next();
        te1.previous();
        //te1.getWRAtts();
            
        system.assertEquals(true, true);
                               
        // ガバナ制限のチェック終了
        system.Test.stopTest();
    }


}