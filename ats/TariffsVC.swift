import UIKit
import CoreData

class TariffsViewController: UIViewController {
    let tableView = UITableView()
    var tariffs: [Tariff] = []
    let managedContext = CoreDataStack.shared.managedContext

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Tariffs"
        setupTableView()
        loadTariffs()

        // Add tariff
        let addTariffButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addTariffButtonTapped))
    
        
        navigationItem.backBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(backButtonTaped))
        let exportButton = UIBarButtonItem(title: "Export", style: .plain, target: self, action: #selector(exportButtonTapped))
        navigationItem.rightBarButtonItems = [exportButton, addTariffButton]
    }

    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "TariffCell")
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

    func loadTariffs() {
        let fetchRequest = NSFetchRequest<Tariff>(entityName: "Tariff")
        do {
            tariffs = try managedContext.fetch(fetchRequest)
            tableView.reloadData()
        } catch let error as NSError {
            print("Error fetching tariffs \(error), \(error.userInfo)")
        }
    }
    @objc func backButtonTaped() {
        navigationController?.popViewController(animated: true)
    }

    @objc func addTariffButtonTapped() {
      let alert = UIAlertController(title: "Add Tariff", message: "Enter tariff details", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.placeholder = "Name"
        }
        alert.addTextField { textField in
            textField.placeholder = "Льготный (true/false)"
        }
      alert.addTextField { textField in
        textField.placeholder = "Cost"
      }
        alert.addAction(UIAlertAction(title: "Save", style: .default, handler: { [weak self] _ in
            guard let name = alert.textFields?[0].text, !name.isEmpty,
                  let isPreferentialStr = alert.textFields?[1].text,
                  let isPreferential = Bool(isPreferentialStr),
                  let costStr = alert.textFields?[2].text,
              let cost = Double(costStr), cost > 0, cost < 1000 else {
                let alertC = UIAlertController(title: "Ошибка ввода", message: nil, preferredStyle: .alert)
                let action = UIAlertAction(title: "Ок", style: .default)
                alertC.addAction(action)
                  self!.present(alertC, animated: false)
                return
            }

            self?.createTariff(name: name, isPreferential: isPreferential, cost: cost)
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        present(alert, animated: true)
    }

    func createTariff(name: String, isPreferential: Bool, cost: Double) {
        let tariff = Tariff(context: managedContext)
        tariff.name = name
        tariff.isPreferential = isPreferential
        tariff.cost = cost
        CoreDataStack.shared.saveContext()
        loadTariffs()
    }

    @objc func exportButtonTapped() {
        exportTariffAverages()
    }

  func exportTariffAverages() {
    let (fullAverage, preferentialAverage) = calculateAverageTariffs()
      let text = """
                   Средняя стоимость полных тарифов: \(fullAverage)
                   Средняя стоимость льготных тарифов: \(preferentialAverage)
                   """
      saveTextToFile(text: text)
    }

    func calculateAverageTariffs() -> (Double, Double) {
      var fullTariffSum = 0.0
        var fullTariffCount = 0
        var preferentialTariffSum = 0.0
      var preferentialTariffCount = 0

      for tariff in tariffs {
          if let isPreferential = tariff.isPreferential as? Bool {
            if isPreferential {
              preferentialTariffSum += tariff.cost
                preferentialTariffCount += 1
            } else {
                fullTariffSum += tariff.cost
                fullTariffCount += 1
            }
          }
      }
      let fullAverage = fullTariffCount > 0 ? fullTariffSum / Double(fullTariffCount) : 0
      let preferentialAverage = preferentialTariffCount > 0 ? preferentialTariffSum / Double(preferentialTariffCount) : 0
      return (fullAverage, preferentialAverage)
    }

    func saveTextToFile(text: String) {
      let fileName = "tariff_averages.txt"
      guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return }
      let fileURL = documentsDirectory.appendingPathComponent(fileName)

        do {
            try text.write(to: fileURL, atomically: true, encoding: .utf8)
            let activityVC = UIActivityViewController(activityItems: [fileURL], applicationActivities: nil)
            present(activityVC, animated: true)
        } catch {
            print("Error saving text to file: \(error)")
        }
    }
}


extension TariffsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteTariff(at: indexPath)
        }
    }
}

extension TariffsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tariffs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TariffCell", for: indexPath)
        let tariff = tariffs[indexPath.row]
        cell.textLabel?.text = "\(tariff.name ?? "") - \(tariff.isPreferential ? "Льготный" : "Не льготный") - \(tariff.cost)"
        return cell
    }
    private func deleteTariff(at indexPath: IndexPath) {
        let tariffToDelete = tariffs[indexPath.row]
        managedContext.delete(tariffToDelete)
        tariffs.remove(at: indexPath.row)
        CoreDataStack.shared.saveContext()
        tableView.deleteRows(at: [indexPath], with: .automatic)
    }
}
