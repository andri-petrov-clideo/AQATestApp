import PhotosUI
import UIKit

class SliderDemoViewController: UIViewController, CustomSliderViewDelegate, PHPickerViewControllerDelegate {

    private let imageView: UIImageView = {
        let imgView = UIImageView()
        imgView.contentMode = .scaleAspectFit
        imgView.backgroundColor = .clear
        imgView.translatesAutoresizingMaskIntoConstraints = false
        // Temporary image for layout purposes
        if let catImage = UIImage(systemName: "photo.fill") { // Using a generic photo icon
            imgView.image = catImage.withTintColor(.systemGray, renderingMode: .alwaysOriginal)
        }
        return imgView
    }()

    private let addImageButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Choose Photo", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .darkGray
        button.layer.cornerRadius = 8
        button.contentEdgeInsets = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
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
        button.titleLabel?.font = UIFont.systemFont(ofSize: 28, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let incrementButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("+", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 24, weight: .medium)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = UIColor.darkGray.withAlphaComponent(0.7)
        button.layer.cornerRadius = 8
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "xmark"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let resetButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Reset", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private let confirmButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "checkmark"), for: .normal)
        button.tintColor = .white
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .black
        setupUI()
        setupActions()
        customSliderView.delegate = self
        if imageView.image == UIImage(systemName: "photo.fill")?.withTintColor(.systemGray, renderingMode: .alwaysOriginal) {
             // Prompt to pick an image if it's still the placeholder
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    private func setupUI() {
        view.addSubview(imageView)
        view.addSubview(addImageButton)
        view.addSubview(customSliderView)
        view.addSubview(decrementButton)
        view.addSubview(incrementButton)
        view.addSubview(cancelButton)
        view.addSubview(resetButton)
        view.addSubview(confirmButton)

        let buttonWidth: CGFloat = 44

        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            imageView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            imageView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            imageView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.5),

            addImageButton.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
            addImageButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),

            // customSliderView and its increment/decrement buttons
            decrementButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            decrementButton.centerYAnchor.constraint(equalTo: customSliderView.centerYAnchor),
            decrementButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            decrementButton.heightAnchor.constraint(equalToConstant: buttonWidth),

            incrementButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            incrementButton.centerYAnchor.constraint(equalTo: customSliderView.centerYAnchor),
            incrementButton.widthAnchor.constraint(equalToConstant: buttonWidth),
            incrementButton.heightAnchor.constraint(equalToConstant: buttonWidth),
            
            customSliderView.topAnchor.constraint(equalTo: addImageButton.bottomAnchor, constant: 20),
            customSliderView.leadingAnchor.constraint(equalTo: decrementButton.trailingAnchor, constant: 10),
            customSliderView.trailingAnchor.constraint(equalTo: incrementButton.leadingAnchor, constant: -10),
            customSliderView.heightAnchor.constraint(equalToConstant: 80),

            cancelButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            cancelButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            cancelButton.widthAnchor.constraint(equalToConstant: 44),
            cancelButton.heightAnchor.constraint(equalToConstant: 44),

            confirmButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            confirmButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            confirmButton.widthAnchor.constraint(equalToConstant: 44),
            confirmButton.heightAnchor.constraint(equalToConstant: 44),

            resetButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            resetButton.centerYAnchor.constraint(equalTo: cancelButton.centerYAnchor)
        ])
    }

    private func setupActions() {
        addImageButton.addTarget(self, action: #selector(presentImagePicker), for: .touchUpInside)
        cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
        resetButton.addTarget(self, action: #selector(resetAction), for: .touchUpInside)
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
        decrementButton.addTarget(self, action: #selector(decrementSliderValue), for: .touchUpInside)
        incrementButton.addTarget(self, action: #selector(incrementSliderValue), for: .touchUpInside)
    }

    @objc private func presentImagePicker() {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = self
        present(picker, animated: true)
    }

    @objc private func cancelAction() {
        if let navigationController = navigationController {
            navigationController.popViewController(animated: true)
        } else {
            dismiss(animated: true, completion: nil)
        }
    }

    @objc private func resetAction() {
        print("Reset button tapped")
        customSliderView.value = 0
        imageView.transform = .identity
    }

    @objc private func confirmAction() {
        print("Confirm button tapped - Rotation: \(customSliderView.value)")
        // Action for confirming the rotation, e.g., pass the rotated image or settings
    }

    @objc private func decrementSliderValue() {
        let stepValue: Float = 1.0 // Or 5.0 for larger steps
        let newValue = customSliderView.value - stepValue
        customSliderView.value = max(customSliderView.slider.minimumValue, newValue) // Ensure not going below min
    }

    @objc private func incrementSliderValue() {
        let stepValue: Float = 1.0 // Or 5.0 for larger steps
        let newValue = customSliderView.value + stepValue
        customSliderView.value = min(customSliderView.slider.maximumValue, newValue) // Ensure not going above max
    }

    // MARK: - CustomSliderViewDelegate

    func sliderValueChanged(to value: Float) {
        let angle = CGFloat(value) * .pi / 180.0
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
