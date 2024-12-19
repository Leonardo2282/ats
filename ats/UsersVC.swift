import UIKit
import CoreData

class UsersViewController: UIViewController {
    let tableView = UITableView()
    var users: [User] = []
    let managedContext = CoreDataStack.shared.managedContext
    var tariffs: [Tariff] = []
    var selectedTariff: Tariff?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Users"
        setupTableView()
        loadUsers()

        // Add user button
        let addUserButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addUserButtonTapped))
        navigationItem.rightBarButtonItem = addUserButton
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UserCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
      tableView.allowsSelection = false
    }

    func loadUsers() {
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        do {
            users = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print("Error fetching users \(error), \(error.userInfo)")
        }
    }
    func loadTariffs(){
      let fetchRequest = NSFetchRequest<Tariff>(entityName: "Tariff")
        do {
            tariffs = try managedContext.fetch(fetchRequest)
        } catch let error as NSError {
          print("Error fetching tariffs: \(error), \(error.userInfo)")
      }
    }

    @objc func addUserButtonTapped() {
        let alert = UIAlertController(title: "Add User", message: "Enter user details", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Name"
        }
        alert.addTextField { textField in
            textField.placeholder = "Phone number"
        }
      let tariffTextField = UITextField()
      tariffTextField.placeholder = "Select Tariff"
      tariffTextField.inputView = createTariffPicker()
      alert.addTextField { textField in
          textField.inputView = tariffTextField.inputView
          textField.placeholder = "Select Tariff"
          tariffTextField.delegate = self
      }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let name = alert.textFields?[0].text, !name.isEmpty,
                  let phoneNumber = alert.textFields?[1].text, !phoneNumber.isEmpty else { return }
            self?.createUser(name: name, phoneNumber: phoneNumber, tariff: self?.selectedTariff)
        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }
  func createTariffPicker() -> UIPickerView {
      let tariffPicker = UIPickerView()
      tariffPicker.delegate = self
      tariffPicker.dataSource = self
      loadTariffs()
      return tariffPicker
  }

    func createUser(name: String, phoneNumber: String, tariff: Tariff?) {
        let user = User(context: managedContext)
        user.name = name
        user.phoneNumber = phoneNumber
        user.tariff = tariff
        CoreDataStack.shared.saveContext()
        loadUsers()
    }
}


extension UsersViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UserCell", for: indexPath)
        let user = users[indexPath.row]
        cell.textLabel?.text = "\(user.name ?? "") - \(user.phoneNumber ?? "") - \(user.tariff?.name ?? "Default")"
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteUser(at: indexPath)
        }
    }
    func deleteUser(at indexPath: IndexPath) {
        let userToDelete = users[indexPath.row]
        managedContext.delete(userToDelete)
        users.remove(at: indexPath.row)
        CoreDataStack.shared.saveContext()
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}

extension UsersViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return tariffs.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return tariffs[row].name
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        selectedTariff = tariffs[row]
    }
}
extension UsersViewController: UITextFieldDelegate{
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if let inputView = textField.inputView as? UIPickerView {
            if let selected = selectedTariff, let index = tariffs.firstIndex(of: selected){
                inputView.selectRow(index, inComponent: 0, animated: true)
            }
        }
    }
}
