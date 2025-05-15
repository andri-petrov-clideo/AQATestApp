import UIKit

class SettingsViewController: UIViewController {

    private let modeSegmentedControl: UISegmentedControl = {
        let items = ["Режим 1", "Режим 2", "Режим 3"]
        let segmentedControl = UISegmentedControl(items: items)
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        return segmentedControl
    }()

    private let activateModeSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        return uiSwitch
    }()

    private let activateModeLabel: UILabel = {
        let label = UILabel()
        label.text = "Активировать режим"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let backButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Назад", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        title = "Настройки"
        setupUI()
        setupActions()
    }

    private func setupUI() {
        view.addSubview(modeSegmentedControl)

        let switchStackView = UIStackView(arrangedSubviews: [activateModeLabel, activateModeSwitch])
        switchStackView.axis = .horizontal
        switchStackView.spacing = 8
        switchStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchStackView)

        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            modeSegmentedControl.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            modeSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            modeSegmentedControl.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            modeSegmentedControl.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20),

            switchStackView.topAnchor.constraint(equalTo: modeSegmentedControl.bottomAnchor, constant: 30),
            switchStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            backButton.topAnchor.constraint(equalTo: switchStackView.bottomAnchor, constant: 40),
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupActions() {
        backButton.addTarget(self, action: #selector(navigateBack), for: .touchUpInside)
        activateModeSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
        modeSegmentedControl.addTarget(self, action: #selector(segmentedControlValueChanged), for: .valueChanged)
    }

    @objc private func navigateBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func switchValueChanged(_ sender: UISwitch) {
        print("Activate mode switch is now: \(sender.isOn ? "ON" : "OFF")")
    }

    @objc private func segmentedControlValueChanged(_ sender: UISegmentedControl) {
        print("Selected segment index: \(sender.selectedSegmentIndex)")
    }
}
