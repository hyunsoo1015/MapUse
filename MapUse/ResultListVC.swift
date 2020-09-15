import UIKit
import MapKit

class ResultListVC: UITableViewController {
    //여기서 데이터를 검색할거면 검색어를 넘겨받아야 하고
    //앞에서 검색을 하고 여기서는 출력만 할거라면 결과를 넘겨받아야 한다.
    var mapItems: [MKMapItem]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //?? 는 데이터가 nil 이면 뒤의 내용을 리턴
        return mapItems?.count ?? 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell")
        if cell == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: "cell")
        }
        
        //데이터 찾아와서 출력하기
        if let item = mapItems?[indexPath.row] {
            cell!.textLabel?.text = item.name
            cell!.detailTextLabel?.text = item.phoneNumber
        }

        return cell!
    }
    
    //셀을 선택했을 떄 호출되는 메소드
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //선택한 셀에 해당하는 데이터를 찾아옴
        let mapItem = mapItems?[indexPath.row]
        
        let routeVC = self.storyboard?.instantiateViewController(identifier: "RouteVC") as! RouteVC
        routeVC.destination = mapItem
        
        self.navigationController?.pushViewController(routeVC, animated: true)
    }
}
