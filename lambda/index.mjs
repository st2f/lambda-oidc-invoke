export const handler = async (event) => {
  if (event?.shouldFail === true) {
    throw new Error('Failure requested by payload');
  }

  return {
    ok: true,
    payload: event,
  };
};
