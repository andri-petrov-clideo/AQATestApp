import PhotosUI
import UIKit

class SliderDemoViewController: UIViewController, CustomSliderViewDelegate, PHPickerViewControllerDelegate {

    private let imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.backgroundColor = .lightGray // Placeholder color
        imgView.translatesAutoresizingMaskIntoConstraints = false
        return imgView
    }()

    private let addImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить изображение", for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let customSliderView: CustomSliderView = {
        let sliderView = CustomSliderView()
        sliderView.translatesAutoresizingMaskIntoConstraints = false
        return sliderView
    }()

    private let decrementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("–", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let incrementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .bold)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
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
        title = "Демо слайдера"
        setupUI()
        setupActions()
        customSliderView.delegate = self
    }

    private func setupUI() {
        view.addSubview(imageView)
        view.addSubview(addImageButton)
        view.addSubview(customSliderView)
        view.addSubview(decrementButton)
        view.addSubview(incrementButton)
        view.addSubview(backButton)

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.4),

            addImageButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            addImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            customSliderView.leadingAnchor.constraint(equalTo: decrementButton.trailingAnchor, constant: 10),
            customSliderView.trailingAnchor.constraint(equalTo: incrementButton.leadingAnchor, constant: -10),
            customSliderView.bottomAnchor.constraint(equalTo: backButton.topAnchor, constant: -20),
            customSliderView.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            decrementButton.centerYAnchor.constraint(equalTo: customSliderView.centerYAnchor, constant: -10),
            decrementButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            decrementButton.widthAnchor.constraint(equalToConstant: 44),
            decrementButton.heightAnchor.constraint(equalToConstant: 44),

            incrementButton.centerYAnchor.constraint(equalTo: customSliderView.centerYAnchor, constant: -10),
            incrementButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            incrementButton.widthAnchor.constraint(equalToConstant: 44),
            incrementButton.heightAnchor.constraint(equalToConstant: 44),

            customSliderView.widthAnchor.constraint(greaterThanOrEqualToConstant: 150),

            backButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            backButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }

    private func setupActions() {
        addImageButton.addTarget(self, action: #selector(presentImagePicker), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(navigateBack), for: .touchUpInside)
        incrementButton.addTarget(self, action: #selector(incrementSlider), for: .touchUpInside)
        decrementButton.addTarget(self, action: #selector(decrementSlider), for: .touchUpInside)
    }

    @objc private func presentImagePicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func navigateBack() {
        navigationController?.popViewController(animated: true)
    }

    @objc private func incrementSlider() {
        let newValue = min(customSliderView.value + 1, 100)
        customSliderView.value = newValue
        // Delegate method will handle rotation
    }

    @objc private func decrementSlider() {
        let newValue = max(customSliderView.value - 1, -100)
        customSliderView.value = newValue
    }

    // MARK: - CustomSliderViewDelegate

    func sliderValueChanged(to value: Float) {
        let angle = CGFloat(value) * .pi / 180.0 // Convert degrees to radians
        UIView.animate(withDuration: 0.1) {
            self.imageView.transform = CGAffineTransform(rotationAngle: angle)
        }
    }

    // MARK: - PHPickerViewControllerDelegate

    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true)
        guard let provider = results.first?.itemProvider else { return }
        if provider.canLoadObject(ofClass: UIImage.self) {
            provider.loadObject(ofClass: UIImage.self) { [weak self] image, error in
                DispatchQueue.main.async {
                    if let image = image as? UIImage {
                        self?.imageView.image = image
                        self?.customSliderView.value = 0
                        self?.imageView.transform = .identity
                    } else if let error = error {
                        print("Error loading image: \(error.localizedDescription)")
                    }
                }
            }
        }
    }
}
