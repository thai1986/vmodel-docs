Traceability Matrix
===================

.. raw:: html
    <table border="1" cellspacing="0" cellpadding="6">
  <thead>
    <tr>
      <th>ID</th>
      <th>Type</th>
      <th>Description</th>
      <th>Derived From</th>
      <th>Implemented By</th>
      <th>Verified By</th>
    </tr>
  </thead>
  <tbody>
    <tr>
      <td>REQ_BUS_001</td>
      <td>Business Requirement</td>
      <td>Users must securely log in</td>
      <td>—</td>
      <td>—</td>
      <td>VAL_001</td>
    </tr>
    <tr>
      <td>REQ_SYS_001</td>
      <td>System Requirement</td>
      <td>System shall authenticate via OAuth2</td>
      <td>REQ_BUS_001</td>
      <td>—</td>
      <td>TC_ACC_001</td>
    </tr>
    <tr>
      <td>REQ_SW_001</td>
      <td>Software Requirement</td>
      <td>SWC shall process CAN messages within 10ms</td>
      <td>REQ_SYS_001</td>
      <td>process_can.c</td>
      <td>TC_UNIT_001</td>
    </tr>
    <tr>
      <td>DES_001</td>
      <td>Specification</td>
      <td>Runnable polls CAN buffer every 10ms</td>
      <td>REQ_SW_001</td>
      <td>IMPL_001</td>
      <td>TC_UNIT_001</td>
    </tr>
    <tr>
      <td>IMPL_001</td>
      <td>Implementation</td>
      <td>C code for CAN polling runnable</td>
      <td>DES_001</td>
      <td>src/swc/process_can.c</td>
      <td>TC_UNIT_001</td>
    </tr>
    <tr>
      <td>TC_UNIT_001</td>
      <td>Unit Test</td>
      <td>Verifies CAN message processing timing</td>
      <td>REQ_SW_001</td>
      <td>tests/test_process_can.c</td>
      <td>—</td>
    </tr>
    <tr>
      <td>TC_ACC_001</td>
      <td>Acceptance Test</td>
      <td>Validates OAuth2 login flow</td>
      <td>REQ_SYS_001</td>
      <td>—</td>
      <td>—</td>
    </tr>
    <tr>
      <td>VAL_001</td>
      <td>Validation</td>
      <td>Confirms login and message flow meet business goals</td>
      <td>REQ_BUS_001</td>
      <td>—</td>
      <td>—</td>
    </tr>
  </tbody>
</table>