import UIKit

class MainViewController: UIViewController {

    let numberTextField = UITextField()
    let callButton = UIButton(type: .system)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Dialpad"

        setupUI()
    }

    private func setupUI() {
        // numberTextField
        numberTextField.placeholder = "Enter phone number"
        numberTextField.borderStyle = .roundedRect
        numberTextField.keyboardType = .numberPad
        view.addSubview(numberTextField)
        numberTextField.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            numberTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            numberTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -40),
            numberTextField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            numberTextField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])

        callButton.setTitle("Call", for: .normal)
        callButton.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        view.addSubview(callButton)
        callButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            callButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            callButton.topAnchor.constraint(equalTo: numberTextField.bottomAnchor, constant: 20)
        ])

        let usersButton = UIBarButtonItem(title: "Users", style: .plain, target: self, action: #selector(usersButtonTapped))
        navigationItem.rightBarButtonItem = usersButton

   
       
        
        let tariffsButton = UIBarButtonItem(title: "Tariffs", style: .plain, target: self, action: #selector(tariffsButtonTapped))
        navigationItem.leftBarButtonItem = tariffsButton
    }

    @objc func tariffsButtonTapped() {
        let tariffsViewController = TariffsViewController()
        navigationController?.pushViewController(tariffsViewController, animated: true)
    }

  @objc func usersButtonTapped() {
    let usersViewController = UsersViewController()
    navigationController?.pushViewController(usersViewController, animated: true)
  }

    @objc func callButtonTapped() {
        guard let phoneNumber = numberTextField.text, !phoneNumber.isEmpty else {
            let alert = UIAlertController(title: "Error", message: "Enter a valid number", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .cancel))
            present(alert, animated: true)
            return
        }
        print("Making call to \(phoneNumber)")

        let callViewController = CallViewController()
        callViewController.phoneNumber = phoneNumber
        navigationController?.pushViewController(callViewController, animated: true)
    }
}
