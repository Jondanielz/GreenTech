<?php
/**
 * Controlador de Indicadores y Unidades
 */

require_once __DIR__ . '/../config/database.php';
require_once __DIR__ . '/../models/Unit.php';
require_once __DIR__ . '/../models/Indicator.php';

class IndicatorController {
    private $db;
    private $unit;
    private $indicator;

    public function __construct() {
        $database = new Database();
        $this->db = $database->getConnection();
        $this->unit = new Unit($this->db);
        $this->indicator = new Indicator($this->db);
    }

    // ===== Unidades =====
    public function listUnits() {
        return [ 'success' => true, 'data' => $this->unit->getAll() ];
    }

    public function getUnit($id) {
        $data = $this->unit->getById((int)$id);
        if (!$data) return [ 'success' => false, 'message' => 'Unidad no encontrada' ];
        return [ 'success' => true, 'data' => $data ];
    }

    public function createUnit($input) {
        if (empty($input['name']) || empty($input['symbol'])) {
            return [ 'success' => false, 'message' => 'Nombre y símbolo son requeridos' ];
        }
        $ok = $this->unit->create($input);
        return [ 'success' => $ok, 'message' => $ok ? 'Unidad creada' : 'No se pudo crear la unidad' ];
    }

    public function updateUnit($id, $input) {
        $ok = $this->unit->update((int)$id, $input);
        return [ 'success' => $ok, 'message' => $ok ? 'Unidad actualizada' : 'No se pudo actualizar la unidad' ];
    }

    public function deleteUnit($id) {
        $ok = $this->unit->delete((int)$id);
        return [ 'success' => $ok, 'message' => $ok ? 'Unidad eliminada' : 'No se pudo eliminar la unidad' ];
    }

    // ===== Indicadores =====
    public function listIndicators() {
        return [ 'success' => true, 'data' => $this->indicator->getAll() ];
    }

    public function getIndicator($id) {
        $data = $this->indicator->getById((int)$id);
        if (!$data) return [ 'success' => false, 'message' => 'Indicador no encontrado' ];
        return [ 'success' => true, 'data' => $data ];
    }

    public function createIndicator($input) {
        if (empty($input['name']) || empty($input['unit_id'])) {
            return [ 'success' => false, 'message' => 'Nombre y unidad son requeridos' ];
        }
        $ok = $this->indicator->create($input);
        return [ 'success' => $ok, 'message' => $ok ? 'Indicador creado' : 'No se pudo crear el indicador' ];
    }

    public function updateIndicator($id, $input) {
        $ok = $this->indicator->update((int)$id, $input);
        return [ 'success' => $ok, 'message' => $ok ? 'Indicador actualizado' : 'No se pudo actualizar el indicador' ];
    }

    public function deleteIndicator($id) {
        $ok = $this->indicator->delete((int)$id);
        return [ 'success' => $ok, 'message' => $ok ? 'Indicador eliminado' : 'No se pudo eliminar el indicador' ];
    }
}
?>


