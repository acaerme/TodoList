import UIKit

final class TodoDetailsViewController: UIViewController, TodoDetailsViewProtocol {

    // MARK: - Properties

    var presenter: TodoDetailsPresenterProtocol?
    private let todo: Todo

    // MARK: - UI Elements

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 24)
        label.textAlignment = .left
        return label
    }()

    private let dateLabel: UILabel = {
        let label = UILabel()
        label.textColor = .gray
        label.font = UIFont.systemFont(ofSize: 12)
        label.textAlignment = .center
        return label
    }()

    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.textColor = .white
        textView.font = UIFont.systemFont(ofSize: 16)
        textView.backgroundColor = .clear
        textView.layer.cornerRadius = 12
        textView.isEditable = false
        return textView
    }()

    // MARK: - Initializers

    init(todo: Todo) {
        self.todo = todo
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        navigationController?.navigationBar.tintColor = .systemYellow
        navigationItem.largeTitleDisplayMode = .never

        configureUI()
        addSubviews()
        setupConstraints()
    }

    // MARK: - UI Setup

    private func configureUI() {
        titleLabel.text = todo.title

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        dateLabel.text = dateFormatter.string(from: todo.date)
            .replacingOccurrences(of: ".", with: "/")

        descriptionTextView.text = todo.description ?? "No description"
    }

    private func addSubviews() {
        view.addSubview(titleLabel)
        view.addSubview(dateLabel)
        view.addSubview(descriptionTextView)
    }

    private func setupConstraints() {
        titleLabel.snp.makeConstraints { maker in
            maker.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            maker.left.right.equalToSuperview().inset(20)
        }

        dateLabel.snp.makeConstraints { maker in
            maker.top.equalTo(titleLabel.snp.bottom).offset(8)
            maker.left.equalToSuperview().inset(20)
        }

        descriptionTextView.snp.makeConstraints { maker in
            maker.top.equalTo(dateLabel.snp.bottom).offset(20)
            maker.left.right.equalToSuperview().inset(20)
            maker.height.equalTo(descriptionTextView.contentSize.height)
        }
    }
}
