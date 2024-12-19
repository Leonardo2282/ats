import UIKit
import CoreData

class ContactsViewController: UIViewController {
    let tableView = UITableView()
    var contacts: [Contact] = []
    let managedContext = CoreDataStack.shared.managedContext

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Contacts"
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ContactCell")
        view.addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
        loadContacts()
        // Add contact
        let addContactButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addContactButtonTapped))
        navigationItem.rightBarButtonItem = addContactButton
    }

    func loadContacts() {
        let fetchRequest = NSFetchRequest<Contact>(entityName: "Contact")
        do {
            contacts = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print("Error fetching contacts \(error), \(error.userInfo)")
        }
    }

    @objc func addContactButtonTapped() {
        let alert = UIAlertController(title: "Add Contact", message: "Enter contact details", preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Name"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Phone number"
        }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] (_) in
            guard let name = alert.textFields?.first?.text, !name.isEmpty,
                let phoneNumber = alert.textFields?.last?.text, !phoneNumber.isEmpty else { return }

            self?.createContact(name: name, phoneNumber: phoneNumber)

        }))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func createContact(name: String, phoneNumber: String) {
        let contact = Contact(context: managedContext)
        contact.name = name
        contact.phoneNumber = phoneNumber
        CoreDataStack.shared.saveContext()
        loadContacts() // reload contacts after save
    }
}

// MARK: - UITableViewDelegate
extension ContactsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let contact = contacts[indexPath.row]
        let callViewController = CallViewController()
        callViewController.phoneNumber = contact.phoneNumber
        navigationController?.pushViewController(callViewController, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension ContactsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contacts.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ContactCell", for: indexPath)
        let contact = contacts[indexPath.row]
        cell.textLabel?.text = "\(contact.name ?? "") - \(contact.phoneNumber ?? "")"
        return cell
    }
}
