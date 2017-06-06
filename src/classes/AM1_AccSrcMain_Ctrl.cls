public with sharing class AM1_AccSrcMain_Ctrl {
    
    // エラーメッセージ
    public string strMessage { get; set; }
    public string ToastDisp { get; set; }
    
    public string baseUrl {get; set;}
    
    // 最近参照した取引先
    private Map<integer,clsAcc> recAccMap = new Map<integer,clsAcc>();    
    // 検索した画面用    
    private Map<integer,clsAcc> srcAccMap = new Map<integer,clsAcc>();
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
    
    // 業種表示
    public List<clsInds> dispInds { get; set; }
    // 業種クラス
    public class clsInds {
        public integer index {get; set;}
        public string industryName {get; set;}
        public string industryUpView {get; set;}
        public string industryDownView {get; set;}
        public Set<String> setIndustry {get; set;}
        public string chooseIndustry {get; set;}
        public string chooseVisibly {get; set;}
    }
    // 選択された業種
    public string SelectICategory {get; set;}
    public string SelectIndustry1 {get; set;}
    public string SelectIndustry2 {get; set;}
    public string SelectIndustry3 {get; set;}
    // 業種セット　カテゴリ，１，２，３
    private Set<String> setICategory = new Set<String>();
    private Set<String> setIndustry1 = new Set<String>();
    private Set<String> setIndustry2 = new Set<String>();
    private Set<String> setIndustry3 = new Set<String>();
    // 業種マップ１(カテゴリ - 業種１)
    // Map<String,Set<String>> MapCategory = new Map<String,Set<String>>();
    // 業種マップ１(業種1 - 業種2)
    // Map<String,Set<String>> MapGyousyu1 = new Map<String,Set<String>>();
    // 業種マップ２(業種2 - 業種3)
    // Map<String,Set<String>> MapGyousyu2 = new Map<String,Set<String>>();
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
            recAccMap.put(iCnt + 1,wkcAcc);
        }
        // teppei chg end

        // 業種で抽出
        SelectICategory = '';
        SelectIndustry1 = '';
        SelectIndustry2 = '';
        SelectIndustry3 = '';
        setICategory = new Set<String>();
        //setIndustry1 = new Set<String>();
        //setIndustry2 = new Set<String>();
        //setIndustry3 = new Set<String>();
        //MapGyousyu1 = new Map<String,Set<String>>();
        //MapGyousyu2 = new Map<String,Set<String>>();
        string strSOQL = 'select lbc_industry_name1__c,lbc_industry_name2__c,lbc_industry_name3__c';
        strSOQL += ' from Account ';
        strSOQL += ' where lbc_office_id__c != null ';
        strSOQL += ' and (lbc_industry_name1__c != null or lbc_industry_name2__c != null or lbc_industry_name3__c != null)';
        strSOQL += ' Limit 50000 ';
        List<Account> industlyAccList = Database.query(strSOQL);
        for(Account acc : industlyAccList){
            string wkGyoshu1 = acc.lbc_industry_name1__c;
            //string wkGyoshu2 = acc.lbc_industry_name2__c;
            //string wkGyoshu3 = acc.lbc_industry_name3__c;
            string wkCategory = wkGyoshu1;
            if(wkGyoshu1 != null && wkGyoshu1.indexof('】') > -1) {
                wkCategory = wkGyoshu1.substring(0,wkGyoshu1.indexof('】') + 1);
            }
            if(wkCategory != null) setICategory.add(wkCategory);
            //if(wkGyoshu1 != null) setIndustry1.add(wkGyoshu1);
            //if(wkGyoshu2 != null) setIndustry2.add(wkGyoshu2);
           // if(wkGyoshu3 != null) setIndustry3.add(wkGyoshu3);

            //if(wkCategory != null){
                //Set<string> setGyoshu1 = new Set<string>();
                //if(MapCategory.containsKey(wkCategory)) setGyoshu1 = MapCategory.get(wkCategory);
                //setGyoshu1.add(wkGyoshu1);
                //MapCategory.put(wkCategory,setGyoshu1);
            //}
            //if(wkGyoshu1 != null){
            //    Set<string> setGyoshu2 = new Set<string>();
            //    if(MapGyousyu1.containsKey(wkGyoshu1)) setGyoshu2 = MapGyousyu1.get(wkGyoshu1);
            //    setGyoshu2.add(wkGyoshu2);
            //   MapGyousyu1.put(wkGyoshu1,setGyoshu2);
            //} 
            //if(wkGyoshu2 != null){
            //    Set<string> setGyoshu3 = new Set<string>();
            //    if(MapGyousyu2.containsKey(wkGyoshu2)) setGyoshu3 = MapGyousyu2.get(wkGyoshu2);
            //    setGyoshu3.add(wkGyoshu3);
            //    MapGyousyu2.put(wkGyoshu2,setGyoshu3);
            //} 
        }

        // 業種初期化
        dispInds = new List<clsInds>();
        for(integer i = 0; i < 4; i++){ // 4　→ 1
            clsInds ind = new clsInds();
            ind.index = i;
            if(i == 0){
                ind.industryName = '業種カテゴリ';
            }
            else{
                ind.industryName = '業種' + ind.index;
            }
            ind.industryUpView = '';
            ind.industryDownView = 'display:none';
            ind.chooseVisibly = 'display:none';
            ind.chooseIndustry = '';
            if(ind.index == 0) ind.setIndustry = setICategory;
            //if(ind.index == 1) ind.setIndustry = setIndustry1;
            //if(ind.index == 2) ind.setIndustry = setIndustry2;
            //if(ind.index == 3) ind.setIndustry = setIndustry3;
            dispInds.add(ind);
        }
        // 最近参照した取引先から表示
        SetRecentAcc();

        // URLパラメータが設定されている場合、業種の抽出
        String paramItem = ApexPages.CurrentPage().getParameters().get('item');
        String paramValue = ApexPages.CurrentPage().getParameters().get('value');
        if(paramItem != null && paramValue != null){
            chooseItem = integer.valueOf(paramItem);
            chooseValue = paramValue;
            chooseIndustry();
        }
    }

    // 業種選択時の処理
    public integer selectIndustly{ get; set; }
    public void openIndustryList(){
        for(integer i = 0; i < dispInds.size(); i++){
            if(selectIndustly == dispInds[i].index){
                if(dispInds[i].industryUpView == 'display:none'){
                    dispInds[i].industryUpView = '';
                    dispInds[i].industryDownView = 'display:none';
                }
                else{
                    dispInds[i].industryUpView = 'display:none';
                    dispInds[i].industryDownView = '';
                }
            }
            else{
                dispInds[i].industryUpView = '';
                dispInds[i].industryDownView = 'display:none';
            }
        }
    }

    // 業種選択時の処理
    public integer chooseItem{ get; set; }
    public string chooseValue{ get; set; }
    public void chooseIndustry(){
        if(chooseValue == null) chooseValue = '';
        dispInds[0].industryUpView = '';
        dispInds[0].industryDownView = 'display:none';
        dispInds[1].industryUpView = '';
        dispInds[1].industryDownView = 'display:none';
        dispInds[2].industryUpView = '';
        dispInds[2].industryDownView = 'display:none';
        dispInds[3].industryUpView = '';
        dispInds[3].industryDownView = 'display:none';

        for(integer i = 0; i < 4; i++){
            if(chooseValue == '') {
                 if(chooseItem <= i){
                    dispInds[i].chooseVisibly =  'display:none';
                    dispInds[i].chooseIndustry = '';
                 }
                 if(chooseItem < i){
                    dispInds[i].setIndustry = null;
                 }
            }
            else{
                if(chooseItem == i){
                    dispInds[i].chooseVisibly = '';
                    dispInds[i].chooseIndustry = chooseValue;
                }

                 if(chooseItem < i){
                    dispInds[i].chooseVisibly =  'display:none';
                    dispInds[i].chooseIndustry = '';
                    dispInds[i].setIndustry = null;
                 }
            }
        }
        if(chooseItem == 0 && chooseValue != ''){
            string strSOQL = 'select lbc_industry_name1__c from Account ';
            strSOQL += ' where lbc_industry_name1__c like \'%' + chooseValue + '%\'';
            strSOQL += ' Limit 50000 ';
            List<Account> accList = Database.query(strSOQL);
            Set<String> strCateg1 = new Set<String>();
            for (Account acc : accList){
                strCateg1.add(acc.lbc_industry_name1__c);
            }
            dispInds[1].setIndustry = strCateg1;
        }
        if(chooseItem == 1 && chooseValue != ''){
            string strSOQL = 'select lbc_industry_name2__c from Account ';
            strSOQL += ' where lbc_industry_name1__c = \'' + chooseValue + '\'';
            strSOQL += ' Limit 50000 ';
            List<Account> accList = Database.query(strSOQL);
            Set<String> strCateg2 = new Set<String>();
            for (Account acc : accList){
                strCateg2.add(acc.lbc_industry_name2__c);
            }
            dispInds[2].setIndustry = strCateg2;
        }
        if(chooseItem == 2 && chooseValue != ''){
            string strSOQL = 'select lbc_industry_name3__c from Account ';
            strSOQL += ' where lbc_industry_name2__c = \'' + chooseValue + '\'';
            strSOQL += ' Limit 50000 ';
            List<Account> accList = Database.query(strSOQL);
            Set<String> strCateg3 = new Set<String>();
            for (Account acc : accList){
                strCateg3.add(acc.lbc_industry_name3__c);
            }
            dispInds[3].setIndustry = strCateg3;
        }

        SelectICategory = dispInds[0].chooseIndustry;
        SelectIndustry1 = dispInds[1].chooseIndustry;
        SelectIndustry2 = dispInds[2].chooseIndustry;
        SelectIndustry3 = dispInds[3].chooseIndustry;

        // すべて解除されたら、 最近参照した取引先から表示
        if(SelectICategory == '' && SelectIndustry1 == '' && SelectIndustry2 == '' && SelectIndustry3 == ''){
            SetRecentAcc();
        }
        else{
            SetIndustryAcc();
        }
    }

    public void SetIndustryAcc(){

        strMessage = '';
        ToastDisp = 'display:none';

        //if(chooseItem == 0) return;
        //if(chooseValue == '') return;
        
        // 取引先取得
        string strSOQL = '';
        strSOQL += 'Select Id, Name, PICSTFPU__c, PICSTFID__r.Name,';
        strSOQL += 'lbc_industry_name1__c,lbc_industry_name2__c,lbc_industry_name3__c';
        strSOQL += ' from Account where lbc_office_id__c != null ';
        if(SelectICategory != ''){
            strSOQL += ' and lbc_industry_name1__c Like \'%' + SelectICategory + '%\'';
        } 
        if(SelectIndustry1 != ''){
            strSOQL += ' and lbc_industry_name1__c = \'' + SelectIndustry1 + '\'';
        } 
        if(SelectIndustry2 != ''){
            strSOQL += ' and lbc_industry_name2__c = \'' + SelectIndustry2 + '\'';
        } 
        if(SelectIndustry3 != ''){
            strSOQL += ' and lbc_industry_name3__c = \'' + SelectIndustry3 + '\'';
        } 
        strSOQL += ' limit 101';

        List<Account> lstAcc = Database.query(strSOQL);
        
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