import { Allotment } from 'allotment';
import React from 'react';
import useStore, { mutateStore } from '../store';
import Hero from '../util/Hero';
import Loading from '../util/Loading';
import { requestUnification } from '../VSCodeAPI';
import UnifyData from './UnifyData';
import UnifyMapView from './UnifyMapView';

const UnifyView = () => {
  const { path, unifications, expandedNodes } = useStore(
    ({ unifyState }) => unifyState
  );
  const {
    selectUnifyStep: selectStep,
    requestUnification,
    toggleUnifyNodeExpanded: toggleNodeExpanded,
  } = mutateStore();

  const hasUnify = path && path.length > 0;

  if (!hasUnify) {
    return (
      <Hero>
        <h1>No unification</h1>
        <p>Please select a command that has unification</p>
      </Hero>
    );
  }

  const unifyMapView = (() => {
    const unifyId = path[0];
    const unification = unifications[unifyId];
    if (unification === undefined) {
      const load = () => {
        requestUnification(unifyId);
      };

      return <Loading refresh={load} />;
    }
    return (
      <UnifyMapView
        {...{
          unification,
          selectStep,
          expandedNodes,
          unifications,
          requestUnification,
          toggleNodeExpanded,
        }}
      />
    );
  })();

  return (
    <Allotment>
      <Allotment.Pane>{unifyMapView}</Allotment.Pane>
      <Allotment.Pane>
        <UnifyData {...{ selectStep }} />
      </Allotment.Pane>
    </Allotment>
  );
};

export default UnifyView;
