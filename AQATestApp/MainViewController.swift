import UIKit

class MainViewController: UIViewController {

    private let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Тестовое приложение"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let toSettingsButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Перейти в настройки", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let toSliderDemoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Перейти в слайдер", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let testSwitch: UISwitch = {
        let uiSwitch = UISwitch()
        uiSwitch.translatesAutoresizingMaskIntoConstraints = false
        return uiSwitch
    }()

    private let testSwitchLabel: UILabel = {
        let label = UILabel()
        label.text = "Тестовый переключатель"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private let demoLabel: UILabel = {
        let label = UILabel()
        label.text = "Demo label"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupUI()
        setupActions()
    }

    private func setupUI() {
        view.addSubview(titleLabel)
        view.addSubview(toSettingsButton)
        view.addSubview(toSliderDemoButton)

        let switchStackView = UIStackView(arrangedSubviews: [testSwitchLabel, testSwitch])
        switchStackView.axis = .horizontal
        switchStackView.spacing = 8
        switchStackView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(switchStackView)

        view.addSubview(demoLabel)

        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 50),
            titleLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            toSettingsButton.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 30),
            toSettingsButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            toSliderDemoButton.topAnchor.constraint(equalTo: toSettingsButton.bottomAnchor, constant: 20),
            toSliderDemoButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            switchStackView.topAnchor.constraint(equalTo: toSliderDemoButton.bottomAnchor, constant: 30),
            switchStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            demoLabel.topAnchor.constraint(equalTo: switchStackView.bottomAnchor, constant: 30),
            demoLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupActions() {
        toSettingsButton.addTarget(self, action: #selector(navigateToSettings), for: .touchUpInside)
        toSliderDemoButton.addTarget(self, action: #selector(navigateToSliderDemo), for: .touchUpInside)
        testSwitch.addTarget(self, action: #selector(switchValueChanged), for: .valueChanged)
    }

    @objc private func navigateToSettings() {
        let settingsVC = SettingsViewController()
        navigationController?.pushViewController(settingsVC, animated: true)
    }

    @objc private func navigateToSliderDemo() {
        let sliderDemoVC = SliderDemoViewController()
        navigationController?.pushViewController(sliderDemoVC, animated: true)
    }

    @objc private func switchValueChanged(_ sender: UISwitch) {
        print("Test switch is now: \(sender.isOn ? "ON" : "OFF")")
    }
}
