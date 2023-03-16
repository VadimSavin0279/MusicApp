import UIKit
import SDWebImage

protocol SearchDisplayLogic: AnyObject {
    func displayData(viewModel: Search.Model.ViewModel.ViewModelData)
}

class SearchViewController: UIViewController, SearchDisplayLogic {
    
    var interactor: SearchBusinessLogic?
    var router: (NSObjectProtocol & SearchRoutingLogic)?
    
    @IBOutlet weak var table: UITableView!
    private var searchViewModel = SearchViewModel(cells: [])
    private var timer: Timer?
    
    let footerView = CustomFooterView()
    let headerView: UILabel = {
        let label = UILabel()
        label.text = "Please enter search term above ..."
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        label.sizeToFit()
        return label
    }()
    
    var numberOfRows: Int {
        return searchViewModel.cells.count
    }
    
    var transitionDelegate: TransitionDelegate?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    // MARK: Setup
    
    private func setup() {
        let viewController        = self
        let interactor            = SearchInteractor()
        let presenter             = SearchPresenter()
        let router                = SearchRouter()
        viewController.interactor = interactor
        viewController.router     = router
        interactor.presenter      = presenter
        presenter.viewController  = viewController
        router.viewController     = viewController
    }
    
    // MARK: - View lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSearchBar()
        table.register(UINib(nibName: "CellForSearchResult", bundle: nil), forCellReuseIdentifier: "cell")
        table.tableFooterView = footerView
        setUpHeaderViewForTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        let keyWindow = UIApplication.shared.connectedScenes.filter({ $0.activationState == .foregroundActive }).map({$0 as? UIWindowScene}).compactMap({$0}).first?.windows.filter({$0.isKeyWindow}).first
        let tabBarVC = keyWindow?.rootViewController as? MainTabBarController
        tabBarVC?.trackView.delegate = self
    }
    
    private func setUpHeaderViewForTableView() {
        table.tableHeaderView = headerView
    }
    
    // MARK: - Display data
    
    func displayData(viewModel: Search.Model.ViewModel.ViewModelData) {
        switch viewModel {
        case .displayTracks(let searchViewModel):
            self.searchViewModel = searchViewModel
            table.reloadData()
            footerView.hideIndicator()
        case .displayFooterView:
            footerView.showLoader()
        case .displayHeaderView:
            table.tableHeaderView?.isHidden = false
        case .hideHeaderView:
            table.tableHeaderView?.isHidden = true
        case .displayNewTrack(let newIndexPath):
            guard let indexPath = table.indexPathForSelectedRow else { return }
            table.deselectRow(at: indexPath, animated: false)
            table.selectRow(at: newIndexPath, animated: false, scrollPosition: .none)
            transitionDelegate?.trackView.setup(viewModel: searchViewModel.cells[newIndexPath.row])
        }
    }
    
    private func hideKeyboard() {
        navigationItem.searchController?.searchBar.searchTextField.resignFirstResponder()
    }
    
    private func setupSearchBar() {
        let searchVC = UISearchController()
        searchVC.searchBar.delegate = self
        navigationItem.searchController = searchVC
    }
    
    private func showTrackDetailView(viewModel: Track?) {
        transitionDelegate?.increseView(viewModel: viewModel)
    }
}

// MARK: - UITableViewDelegate and UITableViewDataSource methods

extension SearchViewController: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        numberOfRows
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as? CellForSearchResult else { return UITableViewCell() }
        cell.configureCellForSearchResult(viewModel: searchViewModel.cells[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return view.bounds.height * 0.09
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        showTrackDetailView(viewModel: searchViewModel.cells[indexPath.row] == transitionDelegate?.trackView.viewModel ? nil : searchViewModel.cells[indexPath.row])
        hideKeyboard()
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        hideKeyboard()
    }
}

// MARK: - UISearchBarDelegate methods

extension SearchViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false, block: { _ in
            self.interactor?.makeRequest(request: .getTracks(searchText))
        })
    }
}


// MARK: - TrackMovingDelegate methods

extension SearchViewController: TrackMovingDelegate {
    func moveBackForPreviousTrack() {
        guard let indexPath = table.indexPathForSelectedRow else { return }
        interactor?.makeRequest(request: .getNextOrPreviousTrack(searchViewModel.cells.count, indexPath, false))
    }
    
    func moveForwardForPreviousTrack() {
        guard let indexPath = table.indexPathForSelectedRow else { return }
        interactor?.makeRequest(request: .getNextOrPreviousTrack(searchViewModel.cells.count, indexPath, true))
    }
}
