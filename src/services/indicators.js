import APIClient from '../utils/api-client.js';

class IndicatorsService {
  async listUnits() { return APIClient.get('/units'); }
  async createUnit(data) { return APIClient.post('/units', data); }
  async updateUnit(id, data) { return APIClient.put(`/units/${id}`, data); }
  async deleteUnit(id) { return APIClient.delete(`/units/${id}`); }

  async listIndicators() { return APIClient.get('/indicators'); }
  async createIndicator(data) { return APIClient.post('/indicators', data); }
  async updateIndicator(id, data) { return APIClient.put(`/indicators/${id}`, data); }
  async deleteIndicator(id) { return APIClient.delete(`/indicators/${id}`); }
}

export default new IndicatorsService();


