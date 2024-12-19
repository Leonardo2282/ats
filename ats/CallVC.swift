import UIKit
import CoreData

class CallViewController: UIViewController {

  var phoneNumber: String?
    let phoneNumberLabel = UILabel()
    let callInfoLabel = UILabel()
    let endCallButton = UIButton(type: .system)
    //let callManager = CallManager()
    let managedContext = CoreDataStack.shared.managedContext

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Active call"

        setupUI()
        displayCallInfo()
    }

    private func setupUI() {
        //phoneNumberLabel
        phoneNumberLabel.font = UIFont.systemFont(ofSize: 20)
        phoneNumberLabel.textAlignment = .center
        view.addSubview(phoneNumberLabel)
        phoneNumberLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            phoneNumberLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            phoneNumberLabel.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -80),
            phoneNumberLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
            phoneNumberLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])

      //callInfoLabel
      callInfoLabel.font = UIFont.systemFont(ofSize: 16)
        callInfoLabel.textAlignment = .center
        callInfoLabel.numberOfLines = 0
        view.addSubview(callInfoLabel)
      callInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            callInfoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),
          callInfoLabel.topAnchor.constraint(equalTo: phoneNumberLabel.bottomAnchor, constant: 20),
          callInfoLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 30),
          callInfoLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -30)
        ])

        // endCallButton
        endCallButton.setTitle("End call", for: .normal)
        endCallButton.addTarget(self, action: #selector(endCallButtonTapped), for: .touchUpInside)
        view.addSubview(endCallButton)
        endCallButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            endCallButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            endCallButton.topAnchor.constraint(equalTo: callInfoLabel.bottomAnchor, constant: 20)
        ])
    }
  
  func displayCallInfo() {
        guard let phoneNumber = phoneNumber else {
            phoneNumberLabel.text = "Unknown number"
            callInfoLabel.text = ""
            return
        }
        phoneNumberLabel.text = "Calling: \(phoneNumber)"
        if let user = findUser(by: phoneNumber) {
            let tariff = user.tariff
            let cost = calculateCallCost(tariff: tariff)
          callInfoLabel.text = "User: \(user.name ?? "Unknown")\nTariff: \(tariff?.name ?? "Default")\nCall cost: \(cost)"
        } else {
          callInfoLabel.text = "User info not found"
        }
    }

    @objc func endCallButtonTapped() {
        print("Ending call")
        navigationController?.popViewController(animated: true)
    }
    
    private func findUser(by phoneNumber: String) -> User? {
        let fetchRequest = NSFetchRequest<User>(entityName: "User")
        fetchRequest.predicate = NSPredicate(format: "phoneNumber == %@", phoneNumber)
        do {
            let users = try managedContext.fetch(fetchRequest)
          return users.first
        } catch {
            print("Error fetching user: \(error)")
            return nil
        }
    }

    private func calculateCallCost(tariff: Tariff?) -> Double {
        guard let tariff = tariff else { return 0 }
        let callDuration = 60.0
        let costPerMinute = tariff.cost / 60.0
        return callDuration * costPerMinute
    }
}
