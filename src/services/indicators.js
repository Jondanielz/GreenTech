import APIClient from '/src/utils/api-client.js';

class IndicatorsService {
  // Unidades
  async listUnits() { return APIClient.get('/units'); }
  async getUnits() { return this.listUnits(); }
  async createUnit(data) { return APIClient.post('/units', data); }
  async updateUnit(id, data) { return APIClient.put(`/units/${id}`, data); }
  async deleteUnit(id) { return APIClient.delete(`/units/${id}`); }

  // Indicadores
  async listIndicators() { return APIClient.get('/indicators'); }
  async getIndicators() { return this.listIndicators(); }
  async createIndicator(data) { return APIClient.post('/indicators', data); }
  async updateIndicator(id, data) { return APIClient.put(`/indicators/${id}`, data); }
  async deleteIndicator(id) { return APIClient.delete(`/indicators/${id}`); }
}

export default new IndicatorsService();


