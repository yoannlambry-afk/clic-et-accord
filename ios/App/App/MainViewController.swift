import UIKit
import Capacitor

/// Enregistre le plugin natif du métronome au chargement du pont Capacitor.
class MainViewController: CAPBridgeViewController {
    override open func capacitorDidLoad() {
        bridge?.registerPluginInstance(MetroPlayerPlugin())
    }
}
