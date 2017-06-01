public with sharing class AM1_AccSrcMain_Ctrl {
    
    // エラーメッセージ
    public string strMessage { get; set; }
    public string ToastDisp { get; set; }
    
    public string baseUrl {get; set;}
    
    // 最近参照した取引先
    public Map<integer,clsAcc> recAccMap = new Map<integer,clsAcc>();    
    // 検索した画面用    
    public Map<integer,clsAcc> srcAccMap = new Map<integer,clsAcc>();
    // 取得データ
    public List<clsAcc> ALLAtts { get; set; }
    // 詳細表示画面用
    public List<clsAcc> dispAccs { get; set; }
    
    // 取引先クラス
    public class clsAcc {
        // 取引先id
        public String TorihikisakiId { get; set; }
        // 取引先名
        public String TorihikisakiNm { get; set; }
        // 行番号
        public Integer lineNo { get; set; }
        // 営業担当PU
        public String EigyotantouPU { get; set; }
        // 営業担当
        public String EigyotantouNm { get; set; }
        // 業種１
        public String Gyousyu1 { get; set; }
        // 業種２
        public String Gyousyu2 { get; set; }
        // 業種３
        public String Gyousyu3 { get; set; }
        // コンストラクタ
        public clsAcc () {
            lineNo = 0;
            TorihikisakiId = '';
            EigyotantouPU = '';
            EigyotantouNm = '';
            Gyousyu1 = '';
            Gyousyu2 = '';
            Gyousyu3 = '';
        }
    }
    
    // ページ情報
    public String page { get; set; }
    // ページカウント
    public integer intPage { get; set; }
    // 最終ページ
    public Integer LastPage { get; set; }
    // 最大表示行数
    private static integer intMax = 10;
    
    // コンストラクタ
    public AM1_AccSrcMain_Ctrl (ApexPages.StandardController controller) {
        
        strMessage = '';
        ToastDisp = 'display:none';
        
        baseUrl = URL.getSalesforceBaseUrl().toExternalForm();
        
        recAccMap = new Map<integer,clsAcc>();    
        
        // teppei 最近参照した取引先はこのオブジェクトね
        Set<Id> KeiIds = new Set<Id>();
        string strQuery = 'SELECT Id FROM RecentlyViewed where type = \'Account\' order by LastViewedDate desc limit 20';
        
        // test実行時はRecentlyViewedは使用できない
        if (Test.isRunningTest()){
            strQuery = 'Select Id from Account limit 20';
        }

        for(SObject s: Database.query(strQuery)){
            KeiIds.add(s.id);
        }

        //List<Account> lstKei = [Select Id, Name, PICSTFPU__c, PICSTFID__r.Name,lbc_industry_name1__c,lbc_industry_name2__c,lbc_industry_name3__c from Account];
        // teppei chg start
        // 最近参照した取引先を取得しmapにセット
        //List<Account> lstAcc = [Select Id, Name, PICSTFPU__c, PICSTFID__r.Name,lbc_industry_name1__c,lbc_industry_name2__c,lbc_industry_name3__c from Account where id = :KeiIds];
        List<Account> lstAcc = [Select Id, Name, PICSTFPU__c, PICSTFID__r.Name,lbc_industry_name1__c,lbc_industry_name2__c,lbc_industry_name3__c from Account where id = :KeiIds ORDER BY LastViewedDate desc];
        for(integer iCnt = 0; iCnt < lstAcc.Size(); iCnt ++){
            clsAcc wkcAcc = new clsAcc();
            wkcAcc.lineNo = iCnt + 1;
            wkcAcc.TorihikisakiId = lstAcc[iCnt].id;
            wkcAcc.TorihikisakiNm = lstAcc[iCnt].Name;
            wkcAcc.EigyotantouPU = lstAcc[iCnt].PICSTFPU__c;
            wkcAcc.EigyotantouNm = lstAcc[iCnt].PICSTFID__r.Name;
            wkcAcc.Gyousyu1 = lstAcc[iCnt].lbc_industry_name1__c;
            wkcAcc.Gyousyu2 = lstAcc[iCnt].lbc_industry_name2__c;
            wkcAcc.Gyousyu3 = lstAcc[iCnt].lbc_industry_name3__c;
        
            system.debug(lstAcc[iCnt].Name);
        
            recAccMap.put(iCnt + 1,wkcAcc);
        }
        // teppei chg end
                
        // 最近参照した取引先から表示
        SetRecentAcc();
    }
    
    // 取引先検索
    public string searchKey{ get; set; }
    public void SearchAcc(){

        strMessage = '';
        ToastDisp = 'display:none';

        // 検索文字チェック
        if (searchKey.length() < 1){
            strMessage = '検索文字は1文字以上入力してください。';
            ToastDisp = '';
            return;
        }
        
        // 取引先取得
        List<Account> lstAcc = [Select Id, Name, PICSTFPU__c, PICSTFID__r.Name,lbc_industry_name1__c,lbc_industry_name2__c,lbc_industry_name3__c from Account where Name like :'%'+searchKey+'%' limit 101];
        
        if (lstAcc.Size() == 0){
            strMessage = '検索結果が見つかりません。';
            ToastDisp = '';
            return;
        }
        
        if (lstAcc.Size() >= 100){
            strMessage = '100件以上の結果があります。';
            ToastDisp = '';
        }
        
        srcAccMap = new Map<integer,clsAcc>();  
        for(integer iCnt = 0; iCnt < lstAcc.Size(); iCnt ++){
            clsAcc wkcAcc = new clsAcc();
            wkcAcc.lineNo = iCnt + 1;
            wkcAcc.TorihikisakiId = lstAcc[iCnt].id;
            wkcAcc.TorihikisakiNm = lstAcc[iCnt].Name;
            wkcAcc.EigyotantouPU = lstAcc[iCnt].PICSTFPU__c;
            wkcAcc.EigyotantouNm = lstAcc[iCnt].PICSTFID__r.Name;
            wkcAcc.Gyousyu1 = lstAcc[iCnt].lbc_industry_name1__c;
            wkcAcc.Gyousyu2 = lstAcc[iCnt].lbc_industry_name2__c;
            wkcAcc.Gyousyu3 = lstAcc[iCnt].lbc_industry_name3__c;
            srcAccMap.put(iCnt + 1,wkcAcc);
        }
        
        // 検索結果の取引先から表示
        SetSearchAcc();
    }
    
    
    // 取引先を最近参照した取引先に切り替え
    public void SetRecentAcc(){

        // メッセージクリア
        strMessage = '';
        ToastDisp = 'display:none';

        // ページ設定
        intPage = 1;
        LastPage = 1;
        
        ALLAtts = new  List<clsAcc>();
        for(integer i : recAccMap.KeySet()){
            ALLAtts.add(recAccMap.get(i));
        }
        LastPage = Math.ceil((decimal)ALLAtts.Size() / (decimal)intMax).intValue();
        view(intPage);
        strMessage = '';
        ToastDisp = 'display:none';
    }
    
    // 取引先を検索結果の取引先に切り替え
    public void SetSearchAcc(){
        // ページ設定
        intPage = 1;
        LastPage = 1;
        
        ALLAtts = new  List<clsAcc>();
        for(integer i : srcAccMap.KeySet()){
            ALLAtts.add(srcAccMap.get(i));
        }
        LastPage = Math.ceil((decimal)ALLAtts.Size() / (decimal)intMax).intValue();
        view(intPage);
    }
    
    // 表示
    public void view(integer PageMove) {
        
        // 取得したデータが何もない場合は何もしない
        if (ALLAtts.Size() == 0) return;
        
        // 最小または最大を超えたら何もしない
        if (PageMove < 1 || PageMove > LastPage) return;
        
        // 画面一覧設定
        dispAccs = new List<clsAcc>();
        integer intFo = ((PageMove - 1)  * intMax) + 1;
        integer intTo = intFo + intMax - 1;
        
        for(Integer i = 0; i < ALLAtts.Size(); i++) {
            if (i + 1 >= intFo && i + 1 <= intTo) {
                clsAcc atRec = new clsAcc();
                atRec = ALLAtts.get(i);
                dispAccs.add(atRec);
            }
        }
                
        // 現在ページを保存
        intPage = PageMove;
        
        // ページ情報設定
        page = '';
        page += intPage;
        page += ' / ';
        page += LastPage;
    }
    
    // 次へ
    public void next() {
        system.debug('次へ');
        view(intPage + 1);
    }
    // 前へ
    public void previous() {
        view(intPage - 1);
    }
}