public with sharing class AC_WR_GetAttach_Asset {

    // 詳細表示画面用
    public Map<integer,WRAtt> ALLAttMap = new Map<integer,WRAtt>();
    public String Journal_RM { get; set; }
    
    // 画面表示クラス
    public class WRAtt {
        // 行番号
        public Integer lineNo { get; set; }
        // 受注No As_IRH_OrderNo__c
        public String OrderNo { get; set; }
        // 設置完了日時   As_IRH_WorkDateTo__c
        public String  WorkDateTo { get; set; }
        // 設置場所 As_IRH_NonyuNm__c
        public String NonyuNm { get; set; }
        // 代表品名 As_IRH_DelegeteProduct__c
        public String DelegeteProduct { get; set; }
        // お客様担当者　As_IRH_CustomerContactName__c
        public String CustomerContactName { get; set; }
        // 作業担当者 As_IRH_WorkerRf__c
        public String WorkerRf { get; set; }
        // 備考 As_IRH_Biko__c
        public String Biko { get; set; }
        // 添付ファイルURL
        public String pdfUrl { get; set; }
        // 添付ファイル表示
        public String dispPdf { get; set; }
        
        // コンストラク タ
        public WRAtt () {
            lineNo = 0;
            OrderNo = '';
            WorkDateTo = '';
            NonyuNm = '';
            DelegeteProduct = '';
            CustomerContactName = '';
            WorkerRf = '';
            Biko = '';
            pdfUrl = '';
            dispPdf = '';
        }
    }

    // 画面一覧
    public List<WRAtt> WRAtts { get; set; }
    // ページ情報
    public String page { get; set; }
    // ページカウント
    public integer intPage { get; set; }
    // 最終ページ
    public Integer LastPage { get; set; }
    // 最大 表示行数
    public integer intMax { get; set; }
    // 取得データ
    public List<WRAtt> ALLAtts { get; set; }

    // コンストラクタ
    public AC_WR_GetAttach_Asset(ApexPages.StandardController controller) {
        // ページ設定
        intPage = 1;
        LastPage = 1;
        intMax = 5;
        ALLAtts = new List<WRAtt>();

        // ログインユーザの取引先責任者を取得 
        string strUsername = UserInfo.getUserName();
        List<user> activeId = [select Id, AccountId,UserType,IsPortalEnabled,ContactId,Contact.NJC_CPJournal_RM__c,LastName,FirstName
                                            from User where Username = : strUsername limit 1];
        List<id> ListAccountid = new List<Id>();
        Journal_RM = 'display:none;';
        if (activeId.size() == 0) return;
        //strAccountid = activeId[0].AccountId;
        // 2017/05/26 add start yoshida
        string strAccountid = activeId[0].AccountId;
        ListAccountid.add(strAccountid);
        // 親に設定した取引先が存在する場合は取得
        ListAccountid.add(strAccountid);
        List<Account> listAccChild = [select id from account where RepresentationCustomer__c = : strAccountid];
        for(Account acc : listAccChild){
            ListAccountid.add(acc.id);
        }
        // 2017/05/26 add end yoshida
        if(activeId[0].Contact.NJC_CPJournal_RM__c) Journal_RM = 'display: inline-block;';
        
        integer intCount = 0;
        Set<Id> UkeIds = new Set<Id>();
        List<As_InstallationReportHed__c> lstUke = [select id
                                                        ,As_IRH_OrderNo__c
                                                        ,As_IRH_WorkDateTo__c
                                                        ,As_IRH_NonyuNm__c
                                                        ,As_IRH_DelegeteProduct__c
                                                        ,As_IRH_CustomerContactName__c
                                                        ,As_IRH_WorkerRf__c
                                                        ,As_IRH_Biko__c
                                                    from As_InstallationReportHed__c
                                                   where As_IRH_ContractDestination__c = : ListAccountid 
                                                        order by CreatedDate desc];
        for(As_InstallationReportHed__c Uke : lstUke){
            UkeIds.add(Uke.Id);
        } 
        
        // 添付ファイル取得(最終のみ取得)test
        Map<id,Attachment> AttMap = new Map<id,Attachment>();
        for(Attachment att : [SELECT Id, Name, CreatedDate,  parentid FROM Attachment
                                         Where parentId = : UkeIds And name like '%.pdf' order by CreatedDate]){
            system.debug('★att:' + att.ParentId);
            AttMap.put(att.ParentId,att);
        }

        // 報告書/対応票の内容を取得
        for (As_InstallationReportHed__c Uke : lstUke ){
        
            // 画面リストに追加
            WRAtt Watt = new WRAtt();
            
            Watt.pdfUrl = '';
            Watt.dispPdf = 'display:none;';
            if(AttMap.containsKey(Uke.id)){
                Attachment att = AttMap.get(Uke.id);
                String baseURL = URL.getSalesforceBaseUrl().toExternalForm();
                if (baseURL.indexof('njccustomerportal') < 0){
                    baseURL = baseURL + '/njccustomerportal';
                }
                Watt.pdfUrl = baseURL + '/servlet/servlet.FileDownload?file=' + att.id;
                Watt.dispPdf = '';

                // 行番号
                Watt.lineNo = intCount + 1;
                // 受注No 
                Watt.OrderNo = Uke.As_IRH_OrderNo__c;
                // 設置完了日時   
                Watt.WorkDateTo = string.valueOf(Uke.As_IRH_WorkDateTo__c);
                // 設置場所
                Watt.NonyuNm = Uke.As_IRH_NonyuNm__c;
                // 代表品名 
                Watt.DelegeteProduct = Uke.As_IRH_DelegeteProduct__c;
                // お客様担当者　
                Watt.CustomerContactName = Uke.As_IRH_CustomerContactName__c;
                // 作業担当者 
                Watt.WorkerRf = Uke.As_IRH_WorkerRf__c;
                // 備考 
                Watt.Biko = Uke.As_IRH_Biko__c;
                
                ALLAtts.add(Watt);
                ALLAttMap.put(intCount + 1,Watt);
    
                // カウントアップ
                intCount += 1;
    
            }
            
        }
        LastPage = Math.ceil((decimal)ALLAtts.Size() / (decimal)intMax).intValue();
        view(intPage);
    }

    // 表示
    public void view(integer PageMove) {
    
        // 取得したデータが何もない場合は何もしない
        if (ALLAtts.Size() == 0) return;

        // 最小または最大を超えたら何もしない
        if (PageMove < 1 || PageMove > LastPage)
        {
            return;
        }

        // 画面一覧設定
        WRAtts = new List<WRAtt>();
        integer intFo = ((PageMove - 1)  * intMax) + 1;
        integer intTo = intFo + intMax - 1;

        for(Integer i=0; i < ALLAtts.Size(); i++) {
            if (i + 1 >= intFo && i + 1 <= intTo) {
                WRAtt atRec = new WRAtt();
                atRec = ALLAtts.get(i);
                WRAtts.add(atRec);
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
    
    // 最初のページへ
    public void first() {
        view(1);
    }
    // 最後のページへ
    public void last() {
        view(LastPage);
    }
    // 次へ
    public void next() {
        view(intPage + 1);
     }
    // 前へ
    public void previous() {
        view(intPage - 1);
    }
    
}